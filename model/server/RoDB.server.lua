local exon = require(game.ReplicatedStorage.exon)

local rodb = exon.rodb

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