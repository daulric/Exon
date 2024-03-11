# Exon Rednet

## This is a networking manager for handling events and connection in your game

## API

### FireServer
```lua
Rednet:FireServer(id: string, ...: any)
```

This sends the data from the client to the server

### FireClient
```lua
Rednet:FireClient(player: Player, id: string, ...: any)
```

This sends the data from the server to a particular client.

### FireAllClients
```lua
Rednet:FireAllClients(id: string, ...: any)
```

This sends the data from the server to all clients

### GetServer
```lua
Rednet:GetServer(id: string, ...: any)
```

This request data from the server on the client side

### GetClient
```lua
Rednet:GetClient(player: Player, id: string, ...: any)
```

This request data from the client on the server side

### listen
```lua
Rednet.listen(id: string, callback: (...any) -> ())
```


This listens for any incomming calls and requests from the client or server

### createSignal
```lua
Rednet.createSignal()
```
This creates a bindable events that can handle communication from client to client or server to server

### createBindableSignal
```lua
Rednet.createBindableSignal()
```

This creates a bindable function that can handle / get data requests from client to client or server to server