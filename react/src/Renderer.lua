local renderer = {}
local markers = script.Parent:WaitForChild("markers")
local Type = require(markers:WaitForChild("Type"))
local ElementType = require(markers:WaitForChild("ElementType"))

local Binding = require(script.Parent:WaitForChild("Binding"))

local Children = require(markers.Children)
local Ref = require(markers.Ref)

local SingleEventManager = require(script.Parent:WaitForChild("SingleEventManager"))

local getDefaultInstanceProperty = require(script.Parent:WaitForChild("getDefaultProperty"))

local function identity(...)
    return ...
end

local function applyRef(ref, newObject)
    if ref == nil then
        return
    end

    if typeof(ref) == "function" then
		ref(newObject)
	elseif ElementType.of(ref) == ElementType.Types.Binding then
		Binding.update(ref, newObject)
	else
		error(("Invalid ref: Expected type Binding but got %s"):format(typeof(ref)))
	end

end

local function removeBinding(virtualNode, key)
    local disconnect = virtualNode.bindings[key]
    disconnect()
    virtualNode.bindings[key] = nil
end

local function setDefaultProperty(object, key, newValue)
    if newValue == nil then
		local hostClass = object.ClassName
		local _, defaultValue = getDefaultInstanceProperty(hostClass, key)
		newValue = defaultValue
	end

	object[key] = newValue

	return
end

local function attachBinding(virtualNode, key, newBinding)
    local function updateBoundProperty(newValue)

		local success, errorMessage = xpcall(function()
			setDefaultProperty(virtualNode.object, key, newValue)
		end, identity)

		if not success then
			local source = virtualNode.currentElement.source

			if source == nil then
				source = "<enable element tracebacks>"
			end

			local fullMessage = ("Apply Props Error (%s) (%s)"):format(errorMessage, source)
			error(fullMessage, 0)
		end
	end

	if virtualNode.bindings == nil then
		virtualNode.bindings = {}
	end

	virtualNode.bindings[key] = Binding.subscribe(newBinding, updateBoundProperty)
	updateBoundProperty(newBinding:getValue())
end

local function detachAllBindings(virtualNode)
    if virtualNode.bindings ~= nil then
		for _, connection in pairs(virtualNode.bindings) do
           if typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
           end
		end

		virtualNode.bindings = nil
	end
end

local function applyProp(virtualNode, key, newValue, oldValue)
    if newValue == oldValue then
        return
    end

    if key == Children or key == Ref then
        return
    end

    local KeyType = ElementType.of(key)

    if KeyType == Type.Event or KeyType == Type.Change or KeyType == Type.AttributeChange then
        if virtualNode.eventManager == nil then
			virtualNode.eventManager = SingleEventManager.new(virtualNode.object)
		end

		local eventName = key.name

		if KeyType == Type.Change then
			virtualNode.eventManager:connectPropertyChange(eventName, newValue)
        elseif KeyType == Type.AttributeChange then
            virtualNode.eventManager:connectAttributeChange(eventName, newValue)
		else
			virtualNode.eventManager:connectEvent(eventName, newValue)
		end

        return
    end

    local newIsBinding = (ElementType.of(newValue) == ElementType.Types.Binding)
    local oldIsBinding = (ElementType.of(oldValue) == ElementType.Types.Binding)

    if oldIsBinding then
        removeBinding(virtualNode, key)
    end

    if newIsBinding then
        attachBinding(virtualNode, key, newValue)
    else
        setDefaultProperty(virtualNode.object, key, newValue)
    end

end

local function applyProps(virtualNode, props)
    for key, value in pairs(props) do
        applyProp(virtualNode, key, value, nil)
    end
end

function updateProps(virtualNode, oldProps, newProps)

    -- Updating Props
    for propKey, newValue in pairs(newProps) do
		local oldValue = oldProps[propKey]
		applyProp(virtualNode, propKey, newValue, oldValue)
	end

    -- Clean up props that were removed
	for propKey, oldValue in pairs(oldProps) do
		local newValue = newProps[propKey]

		if newValue == nil then
			applyProp(virtualNode, propKey, nil, oldValue)
		end
	end

end

function renderer.isHostObject(target)
	return typeof(target) == "Instance"
end

function renderer.mountHostNode(virtualNode, reconciler)
    local element = virtualNode.currentElement
    local hostParent = virtualNode.hostParent

    local instance = Instance.new(element.class)
    virtualNode.object = instance
    instance.Name = tostring(virtualNode.hostKey)

    local success, errorMessage = xpcall(function()
        applyProps(virtualNode, element.props)
    end, identity)

    if not success then

        local source = element.source

		if source == nil then
			source = "<enable element tracebacks>"
		end

        error(source.." : "..errorMessage)

    end

    local children = element.props[Children]

    if children ~= nil then
        reconciler.updateChildren(virtualNode, virtualNode.object, children)
    end

    instance.Parent = hostParent
    virtualNode.object = instance

    applyRef(element.props[Ref], instance)

    if virtualNode.eventManager ~= nil then
        virtualNode.eventManager:resume()
    end

end

function renderer.unmountHostNode(virtualNode, reconciler)
    local element = virtualNode.currentElement

    applyRef(element.props[Ref], nil)

    for i, node in pairs(virtualNode.children) do
        reconciler.unmountNode(node)
    end

    detachAllBindings(virtualNode)
    virtualNode.object:Destroy()
end

function renderer.updateHostNode(virtualNode, reconciler, newElement)
    local oldProps = virtualNode.currentElement.props
    local newProps = newElement.props

    if virtualNode.eventManager then
        virtualNode.eventManager:suspend()
    end

    if oldProps[Ref] ~= newProps[Ref] then
        applyRef(oldProps[Ref], nil)
        applyRef(newProps[Ref], virtualNode.object)
    end

    local success, err = xpcall(function()
        updateProps(virtualNode, oldProps, newProps)
    end, identity)

    if not success then
        local source = newElement.source

        if source == nil then
            source = "<element tracebacks>"
        end

        error(`{source}:{err}`)
    end

    local children = newElement.props[Children]

    if children ~= nil or oldProps[Children] ~= nil then
        reconciler.updateChildren(virtualNode, virtualNode.hostParent, children)
    end

    if virtualNode.eventManager then
        virtualNode.eventManager:resume()
    end

    return virtualNode
end

return renderer