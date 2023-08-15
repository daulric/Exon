local class = {}

local CLASS_METATABLE = {__index = class}

local strongRefs = {}

function class:update()
    for _, callback in pairs(self._changeListeners) do
        task.spawn(callback)
    end

    return false
end

function class:onChange(callback)
    local uniqueIndetifier = {}

    self._numChangeListeners += 1
    self._changeListeners[uniqueIndetifier] = callback

    strongRefs[self] = true

    local disconnected = false

    return function ()
        if disconnected then
            return
        end

        disconnected = true

        self._changeListeners[uniqueIndetifier] = nil
        self._numChangeListeners -= 1

        if self._numChangeListeners == 0 then
            strongRefs[self] = nil
        end

    end

end

function class:onBind(callback: () -> ())
    task.spawn(callback)
    return self:onChange(callback)
end

function Observer(state)
    local self = setmetatable({
		type = "State",
		kind = "Observer",
		dependencySet = {[state] = true},
		dependentSet = {},
		_changeListeners = {},
		_numChangeListeners = 0,
	}, CLASS_METATABLE)

	state.dependentSet[self] = true

	return self
end

return Observer