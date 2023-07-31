local GeneralDB = {}

local internalmessage = require(script.Parent:WaitForChild("internalmessage"))

function GeneralDB:SaveData(mainIndex, RootDB)
    assert(type(mainIndex.isGeneral) == "userdata", `<cannot save data without proper configuration>`)

    if mainIndex.id then
        local success, err = pcall(function()
            RootDB:SaveData(mainIndex, mainIndex.id)
        end)

        assert(success, internalmessage.databaseSaveFail(mainIndex.name, mainIndex.id, err))
        print(internalmessage.databaseSaveSuccess(mainIndex.name, mainIndex.id))
    end

end

function GeneralDB:GetData(mainIndex, RootDB)
    assert(type(mainIndex.isGeneral) == "userdata", `<cannot retrieve data without proper configuration>`)

    if mainIndex.id then
        local success, err = pcall(function()
            RootDB:GetData(mainIndex, mainIndex.id)
        end)

        assert(success, internalmessage.databaseRetrieveFail(mainIndex.name, mainIndex.id, err))
        print(internalmessage.databaseRetrieveSuccess(mainIndex.name, mainIndex.id))
    end

end

return GeneralDB