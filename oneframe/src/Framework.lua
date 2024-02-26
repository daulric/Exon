local Tools = script.Parent:WaitForChild("Tools")
local Promise = require(Tools:WaitForChild("Promise"))

local Marker = require(script.Parent:WaitForChild("Mark"))

local RunService = game:GetService("RunService")

local msgTag = "[Exon OneFrame]:"

function Start(scripts, ...)
    local success, err = pcall(task.spawn, scripts.start, scripts, ...)

    if not success then
        warn(`{msgTag} Error Starting the Code!; {err}`)
    end
end

function preload(scripts, ...)
    if scripts.preload then
        local success, err = pcall(task.spawn, scripts.preload, scripts, ...)

        if not success then
            warn(`{msgTag} Error Preload Code! {err}`)
        end
    end
end

function MsgInfo(ignore, message)
    if not ignore then
        if RunService:IsClient() then
            print("Client:\\\\", message) -- Looks weird cause of roblox string problem
        elseif RunService:IsServer() then
            print("Server:\\\\", message) -- Looks weird cause of roblox string problem
        end
    end
end

function ConnectionTable(scripts, ...)
    task.spawn(function(...)
        preload(scripts, ...)
        task.wait()
        Start(scripts, ...)
    end, ...)

    if scripts.closing and RunService:IsServer() then
        game:BindToClose(function()
            task.spawn(scripts.closing, scripts)
        end)
    end

end

function ConnectionFuncMethod(scripts, ...)
    local items = {...}
    local count = select("#", ...)

    local function onStart(callback)
        return callback(unpack(items, 1, count))
    end

    local function closingmethod(callback)
        if RunService:IsServer() then
            game:BindToClose(function()
                callback()
            end)
        end
    end

    task.spawn(scripts, onStart, closingmethod)
end

function CreateConnection(scripts, Name, ...)
    Name = Name or ""

    local connectType = typeof(scripts)

    assert((connectType ~= "table" or connectType ~= "function"), `{msgTag} There must be a component or a function!`)

    if typeof(scripts) == "table" then
        assert(scripts.name ~= nil, `{msgTag} Must Have a Name!`)
        ConnectionTable(scripts, ...)
    elseif typeof(scripts) == "function" then
        ConnectionFuncMethod(scripts, ...)
    end

    return Name
end

function GetModuleType(module, ignore, ...)
    local success, scripts, Name, Mode = pcall(function()
        local Data = require(module)

        if type(Data) == "table" then
            if Data[Marker] then
                return Data, Data.name, Data[Marker]
            end
        
        elseif typeof(Data) == "function" then
            return Data, module.Name
        end

    end)

    assert(success, `{msgTag} Data could not execute for {Name or module.Name}`)

    if typeof(scripts) == "table" then
        if Mode.test == true and RunService:IsStudio() then
            local message = CreateConnection(scripts, Name, ...)
            MsgInfo(ignore, message)
        else
            local message = CreateConnection(scripts, Name, ...)
            MsgInfo(ignore, message)
        end

    elseif typeof(scripts) == "function" then
        local message = CreateConnection(scripts, Name, ...)
        MsgInfo(ignore, message)
    end

end

function LoopFolder(Folder: Instance, ignore, ...: any)
    for _, instance in pairs(Folder:GetDescendants()) do
        if instance:IsA("ModuleScript") then
            task.spawn(GetModuleType, instance, ignore, ...)
        end
    end
end

function LoopTable(Table, ignore, ...)
    for _, instance in pairs(Table) do
        if typeof(instance) == "Instance"  then
            LoopFolder(instance, ignore, ...)
        elseif typeof(instance) == "table" then
            LoopTable(instance, ignore, ...)
        end
    end
end

function MainFrame(Folder, ...)
    local StartTime = os.time()

    local Items = {...}
    local count = select("#", ...)

    local Success = Promise.new( function(resolve, reject)
        if typeof(Folder) == "Instance" then
            LoopFolder(Folder, nil, unpack(Items, 1, count))
            resolve(Items)
        elseif typeof(Folder) == "table" then
            LoopTable(Folder, nil, unpack(Items, 1, count))
            resolve(Items)
        else
            reject(Items)
        end
    end)

    Success:andThen(function()
        local Finished = os.time() - StartTime
        print(`{Folder.Name} took {Finished} seconds to load!`)
    end)

    return Success
    
end


return MainFrame