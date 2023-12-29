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

    local store = setmetatable({
        isCleaning = false,
        _objects = {}
    }, Tidy)

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

function Tidy:addMultiple(...)
    local items = {...}
    
    for i, v in pairs(items) do
        self:add(v)
    end

    return items
end

function Tidy:remove(object)
    assert(self._cleaning ~= true, "cleaning in process")

    for i, v in pairs(self._objects) do
        if v.object == object then
           self:__cleanObject(v.object, v.Type)
           table.remove(self._objects, i)
        else
            warn("couldn't find", object, "in the cleanup")
        end
    end
end

function Tidy:Contruct(module)
    if module.new then
        local newMode = module.new()
        return self:add(newMode)
    end
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
Tidy.destroy = Tidy.Clean
Tidy.contruct = Tidy.Contruct
Tidy.connect = Tidy.Connect

return Tidy