local PlayerDataStore = {}
local internalmessage = require(script.Parent:WaitForChild("internalmessage"))

function PlayerDataStore:SaveData(mainIndex, RootDB)

    assert(type(mainIndex.isProfile) == "userdata", `<cannot save data without proper configuration!>`)

    if mainIndex.player then

        local success, err = pcall(function()
            RootDB:SaveData(mainIndex, mainIndex.player.UserId)
        end)

        assert(success,internalmessage.databaseSaveFail(mainIndex.name, mainIndex.player.Name, err))
        print(internalmessage.databaseSaveSuccess(mainIndex.name, mainIndex.player.Name))
    end
end

function PlayerDataStore:GetData(mainIndex, RootDB)
    assert(type(mainIndex.isProfile) == "userdata" , `<cannot retrieve data without proper configuration!>`)

    if mainIndex.player then
        local success, err = pcall(function()
            RootDB:GetData(mainIndex, mainIndex.player.UserId)
        end)

        assert(success, internalmessage.databaseRetrieveFail(mainIndex.name, mainIndex.player.Name, err))
        print(internalmessage.databaseRetrieveSuccess(mainIndex.name, mainIndex.player.Name))
    end
end

return PlayerDataStore