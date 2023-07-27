local class = {}

local Packages = script.Parent.Parent

local Log = Packages:WaitForChild("Log")

local refurbish = require(script.Parent:WaitForChild("refurbishAll"))

local CLASS_METATABLE = {__index = class}

local WEAK_KEYS_METATABLE = {__mode = "k"}

function class:set(newValue: any, force: boolean)
    local oldValue = self._value

    if force or not (newValue == oldValue) then
        self._value = newValue
        refurbish(self)
    end

end

function class:_peek()
    return self._value
end

function class:get()
    return self:_peek()
end

function Value(initialValue)
    local self = setmetatable({
		key = "State",
		kind = "Value",
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
		_value = initialValue
	}, CLASS_METATABLE)

	return self
end

return Value