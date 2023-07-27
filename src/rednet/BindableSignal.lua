local BSignal = {}

local CLASS_METATABLE = { __index = BSignal}

function BSignal:Fire(...)
    self._args = {...}
    self._argCount = select("#", ...)
    return self._bindable:Invoke()
end

function BSignal:Connect(handler)
    self._bindable.OnInvoke = function()
        if self._isConnected == true then
            return handler(table.unpack(self._args, 1, self._argCount))
        end
    end
end

function BSignal:Disconnect()
    self._isConnected = false
end

function BSignal:Destroy()
    if self._bindable then
        self._bindable:Destroy()
        self._bindable = nil
    end

    self._argCount = nil
    self._args = nil
    self._isConnected = false
end

function createBindableSignal()
    local self = setmetatable({
        _isConnected = true,
        _args = nil,
        _argCount = nil,
        _bindable = Instance.new("BindableFunction"),
    }, CLASS_METATABLE)

    return self
end

return createBindableSignal