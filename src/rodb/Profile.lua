local PlayerDataStore = {}

function PlayerDataStore:SaveData(mainIndex, RootDB)

    assert(type(mainIndex.isProfile) == "userdata", `<cannot save data without proper configuration!>`)

    if mainIndex.player then

        local success, err = pcall(function()
            RootDB:SaveData(mainIndex, mainIndex.player.UserId)
        end)

        assert(success, `<failed to store data in {mainIndex.name}> : {err}`)
        print(`<successfully saved data in {mainIndex.name}>`)
    end
end

function PlayerDataStore:GetData(mainIndex, RootDB)
    assert(type(mainIndex.isProfile) == "userdata" , `<cannot retrieve data without proper configuration!>`)

    if mainIndex.player then
        local success, err = pcall(function()
            RootDB:GetData(mainIndex, mainIndex.player.UserId)
        end)

        assert(success, `<failed to retrieve data from {mainIndex.name}> : {err} `)
        print(`<successfully retrieved data from {mainIndex.name}`)
    end
end

return PlayerDataStore