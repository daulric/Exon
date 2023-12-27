function import(target)
    
    local targetType = typeof(target)
    local newTarget

    if targetType == "table" then
        newTarget = target
    elseif targetType == "Instance" and target:IsA("ModuleScript") then
        newTarget = require(target)
    else
        error(`the target type was {targetType}; the expected target are either a table or a module script; {debug.traceback()}`)
    end

    return function (paths)
        local importedItems = {}

        assert((type(paths) == "table"), `table not recogized; {debug.traceback()}`)

        for i = 1, #paths do

            local path = paths[i]
            local item

            if string.find(path, "/") then
                local nestedPaths = string.split(path, "/")

                for i, v in pairs(nestedPaths) do
                    if i == 1 then
                        item = newTarget[v]
                    else
                        item = item[v]
                    end
                end

            else
                item = newTarget[path]
            end

            if item ~= nil then
                table.insert(importedItems, item)
            end

        end

        return unpack(importedItems)
    end

end

return import