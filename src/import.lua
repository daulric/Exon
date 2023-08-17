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

    return function (imports)
        assert(type(imports) == "table", `Imports is not a table; {debug.traceback()}`)
        local importedItems = {}

        for i = 1, #imports do
            local item = newTarget[imports[i]]
            assert(item ~= nil, `{imports[i]} is not a member of {target}`)
            table.insert(importedItems, item)
        end

        return unpack(importedItems)
    end

end

return import