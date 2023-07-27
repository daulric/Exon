local GeneralDB = {}

function GeneralDB:SaveData(mainIndex, RootDB)
    assert(type(mainIndex.isGeneral) == "userdata", `<cannot save data without proper configuration>`)

    if mainIndex.id then
        local success, err = pcall(function()
            RootDB:SaveData(mainIndex, mainIndex.id)
        end)

        assert(success, `<failed to store data in {mainIndex.name}> : {err}`)
        print(`<successfully stored data in {mainIndex.name}>`)
    end

end

function GeneralDB:GetData(mainIndex, RootDB)
    assert(type(mainIndex.isGeneral) == "userdata", `<cannot retrieve data without proper configuration>`)

    if mainIndex.id then
        local success, err = pcall(function()
            RootDB:GetData(mainIndex, mainIndex.id)
        end)

        assert(success, `<cannot get retrieve data from {mainIndex.name}> : {err}`)
    end

end

return GeneralDB