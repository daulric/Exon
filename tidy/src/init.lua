local Tidy = {}
Tidy.__index = Tidy

local threadMark = newproxy(true)
local funcMark = newproxy(true)

function getCleaningDetails(obj)

    if typeof(obj) == "RBXScriptConnection" then
        return "Disconnect"
    end

    if typeof(obj) == "Instance" then
        return "Destroy"
    end

    if typeof(obj) == "function" then
        return funcMark
    end

    if typeof(obj) == "thread" then
        return threadMark
    end

    if typeof(obj) == "table" then
        if type(obj.Destroy) == "function" then
            return "Destroy"
        elseif type(obj.destroy) == "function" then
            return "destroy"
        end

        if type(obj.Disconnect) == "function" then
            return "Disconnect"
        elseif type(obj.disconnect) == "function" then
            return "disconnect"
        end
    end

end

function Tidy.init()

    local store = setmetatable({}, Tidy)

    store.isCleaning = false
    store._objects = {}

    return store

end

function Tidy:add(obj)

    assert(self.isCleaning ~= true, `Cleaning in Proccess`)
    local cleanDetail = getCleaningDetails(obj)

    table.insert(self._objects, {
        Type = cleanDetail,
        object = obj
    })

    return obj
end

function Tidy:Connect(signal, callback)
    local connection = signal:Connect(callback)
    return self:add(connection)
end

function Tidy:__cleanObject(object, method)
    if method == funcMark then
        object()
    elseif method == threadMark then
        coroutine.close(object)
    else
        object[method](object)
    end
end

function Tidy:Clean()
    self.isCleaning = true

    for _, v in pairs(self._objects) do
        self:__cleanObject(v.object, v.Type)
    end

    table.clear(self._objects)
    self.isCleaning = false
end

Tidy.clean = Tidy.Clean

return Tidy