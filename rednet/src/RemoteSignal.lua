local Signal = {}
local CLASS_METATABLE = {__index = Signal}

function Signal:Connect(handler)
    return self._bindable.Event:Connect(function()
        if self._isConnected == true then
            handler(table.unpack(self._args, 1, self._argCount))
        end
    end)
end

function Signal:Once(handler)
    return self._bindable.Event:Once(function()
        handler(table.unpack(self._args, 1, self._argCount))
    end)
end

function Signal:Wait()
    if self._args ~= nil then
        self._bindable.Event:Wait()
        return table.unpack(self._args, 1, self._argCount)
    end
end

function Signal:Disconnect()
    self._isConnected = false
end

function Signal:Destroy()
    if self._bindable then
        self._bindable:Destroy()
        self._bindable = nil
    end

    self._argCount = nil
    self._args = nil
    self._isConnected = false
end

function Signal:Fire(...)
    self._args = {...}
    self._argCount = select("#", ...)
    self._bindable:Fire()
end

function createSignal()

    local self =  setmetatable({
        _bindable = Instance.new("BindableEvent"),
        _isConnected = true,
        _args = nil,
        _argCount = nil,
    }, CLASS_METATABLE)

    return self
end

return createSignal