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

function GetListener(temp)

    if temp.id and Listeners[temp.id] then
        return Listeners[temp.id], temp.data
    end

end

function Validate(tempData)
    local success, listener, data = pcall(GetListener, tempData)

    if success and listener ~= nil and data ~= nil then
        return true
    end

end

function NoCallbackMessage(id)
    return `There is no Callback Function; Callback for {id} doesn't exsist!`
end

function ServerListen(player: Player, tempData)
    local listener, data = GetListener(tempData)
    assert(Validate(tempData), NoCallbackMessage(tempData.id))
    return listener._callback(player, unpack(data))
end

function ClientListen(tempData)
    local listener, data = GetListener(tempData)
    assert(Validate(tempData), NoCallbackMessage(tempData.id))
    return listener._callback(unpack(data))
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