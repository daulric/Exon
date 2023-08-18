local RunService = game:GetService("RunService")
local RedNet = {}

local RemoteEvent
local RemoteFunction

if RunService:IsServer() then
    RemoteEvent = Instance.new("RemoteEvent", script)
    RemoteFunction = Instance.new("RemoteFunction", script)
elseif RunService:IsClient() then
    RemoteEvent = script:WaitForChild("RemoteEvent")
    RemoteFunction = script:WaitForChild("RemoteFunction")
end

local Listeners = {}

function ProccessData(id: string, ... : any)

    local tempData = {
        id = id,
        data = {...},
    }

    return tempData
end

function RedNet:FireServer(id: string, ... : any)
    local data = ProccessData(id, ...)
    RemoteEvent:FireServer(data)
end

function RedNet:FireClient(player: Player, id: string, ... : any)
    local data = ProccessData(id, ...)
    RemoteEvent:FireClient(player, data)
end

function RedNet:FireAllClients(id: string, ... : any)
    local data = ProccessData(id, ...)
    RemoteEvent:FireAllClients(data)
end

function RedNet:GetServer(id: string, ... : any)
    local data = ProccessData(id, ...)
    return RemoteFunction:InvokeServer(data)
end

function RedNet:GetClient(player: Player, id: string, ... : any)
    local data = ProccessData(id, ...)
    return RemoteFunction:InvokeClient(player, data)
end

function RedNet.listen(id: string, callback : (...any) -> () )

    if Listeners[id] ~= nil then
        warn(`{id} already exsists! \n\n we'll be returning the signal that correspond to that id!`)
        return Listeners[id]
    end

    local listener = {
        _callback = callback,
    }

    function listener:Disconnect()
        Listeners[id] = nil
    end

    Listeners[id] = listener
    return listener
end

function GetListener(tempData)
    local data = {}

    for i, v in pairs(tempData.data) do
        data[i] = v
    end

    if tempData.id and Listeners[tempData.id] then
        return Listeners[tempData.id], data
    end

end

function ServerListen(player: Player, tempData)
    local success, listener, data = pcall(GetListener, tempData)

    if success then
        return listener._callback(player, unpack(data))
    end
end

function ClientListen(tempData)
    local success, listener, data = pcall(GetListener, tempData)

    if success then
        return listener._callback(unpack(data))
    end
end

if RunService:IsServer() then
    RemoteEvent.OnServerEvent:Connect(ServerListen)
    RemoteFunction.OnServerInvoke = ServerListen
elseif RunService:IsClient() then
    RemoteEvent.OnClientEvent:Connect(ClientListen)
    RemoteFunction.OnClientInvoke = ClientListen
end

RedNet.createSignal = require(script:WaitForChild("RemoteSignal"))
RedNet.createBindableSignal = require(script:WaitForChild("BindableSignal"))

return RedNet