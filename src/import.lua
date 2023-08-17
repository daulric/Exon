return function (target, ...)
    local itemsListed = {...}
    local targetType = typeof(target)
    local newTarget

    local ImportedItems = {}

    if targetType == "table" then
        newTarget = target
    elseif targetType == "Instance" and target:IsA("ModuleScript") then
        newTarget = require(target)
    end

    for i = 1, select("#", ...) do
        assert(newTarget[itemsListed[i]] ~= nil, `This items is not available in {target}`)
        table.insert(ImportedItems, newTarget[itemsListed[i]])
    end

    return unpack(ImportedItems)
end