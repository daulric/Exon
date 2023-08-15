local RootDB = {}

function RootDB:SaveData(mainIndex, id)
    mainIndex.db:UpdateAsync(id, function(oldData)

        if oldData == nil then
            return mainIndex.data
        end

        for i, v in pairs(mainIndex.data) do
            if oldData[i] ~= v then
                oldData[i] = v
            end
        end

        return oldData
    end)
end

function RootDB:GetData(mainIndex, id)
    mainIndex.db:UpdateAsync(id, function(oldData)

        if oldData == nil then
            return mainIndex.data
        end

        for i, v in pairs(oldData) do
            mainIndex.data[i] = v
        end

        return oldData
    end)
end

return RootDB