local devbox = require(game.ReplicatedStorage.devbox)

local rodb = devbox.rodb

local database = rodb.create("Test", "Testing")

database.data = {
    Cryo = {
        Search = "Data",
        Accept = true,
        Deny = false
    },
}

database:Save()
print("Registry:", rodb:GetRegistry())