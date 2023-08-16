local differentDependencies = require(script:WaitForChild("differentDependencies"))
local createUseState = require(script:WaitForChild("createUseState"))
local createUseEffect = require(script:WaitForChild("createUseEffect"))
local createUseBinding = require(script:WaitForChild("createUseBinding"))
local createUseValue = require(script:WaitForChild("createUseValue"))
local createUseMemo = require(script:WaitForChild("createUseMemo"))
local createUseCallback = require(script:WaitForChild("createUseCallback"))
local createUseContext = require(script:WaitForChild("createUseContext"))

function createHooks(react, component)
    local useValue = createUseValue(component)
    local useState = createUseState(component)
    local useEffect = createUseEffect(component)
    local useBinding = createUseBinding(react, useValue)
    local useMemo = createUseMemo(useValue)
    local useCallback = createUseCallback(useMemo)
    local useContext = createUseContext(component, useEffect, useState, useMemo)

    return {
        React = react,
        useBinding = useBinding,
        useCallback = useCallback,
        useContext = useContext,
        useEffect = useEffect,
        useMemo = useMemo,
        useState = useState,
        useValue = useValue,
    }
end

type Hooks = typeof(createHooks())
type Props = {[any]: any}

type render = (Props, Hooks) -> ()

function createReactHook(react)
    return function (render: render, options)

        assert(type(render) == "function", `hooked component have to be a function`)

        if options == nil then
            options = {}
        end

        local componentType = options.componentType
        local name = options.name or debug.info(render, "n")

        local component

        if componentType == nil or componentType == "Component" then
            component = react.Component:extend(name)
        else
            error(
                string.format(
                    "'%s' is not a valid componentType. componentType must either be nil, 'Component'",
					tostring(componentType)
                )
            )
        end

        component.defaultProps = options.defaultProps
        component.validateProps = options.validateProps

        function component:init()
            self.defaultStateValues = {}
            self.effectDependencies = {}
            self.effects = {}
            self.unmountEffects = {}

            self.hooks = createHooks(react, self)
        end

        function component:runEffects()
            for index = 1, self.hookCounter do
				local effectData = self.effects[index]
				if effectData == nil then
					continue
				end

				local effect, dependsOn = unpack(effectData)

				if dependsOn ~= nil then
					local lastDependencies = self.effectDependencies[index]

					if lastDependencies ~= nil and not differentDependencies(dependsOn, lastDependencies) then
						continue
					end

					self.effectDependencies[index] = dependsOn
				end

				local unmountEffect = self.unmountEffects[index]

				if unmountEffect ~= nil then
					unmountEffect()
				end

				self.unmountEffects[index] = effect()
			end
        end

        function component:didMount()
            self:runEffects()
        end

        function component:didUpdate()
            self:runEffects()
        end

        function component:willUnmount()
            for index = 1, self.hookCounter do
				local unmountEffect = self.unmountEffects[index]

				if unmountEffect ~= nil then
					unmountEffect()
				end
			end
        end

        function component:render()
            self.hookCounter = 0
            return render(self.props, self.hooks)
        end

        return component

    end
end

return createReactHook