local differentDependencies = require(script.Parent:WaitForChild("differentDependencies"))

return function(useValue)
    return function (createValue, dependencies)
        local currentVal = useValue(nil)

        local neededRecalulation = dependencies == nil

        if currentVal.value == nil or differentDependencies(dependencies, currentVal.value.dependencies) then
            neededRecalulation = true
        end

        if neededRecalulation then
            currentVal.value = {
				dependencies = dependencies,
				memoizedValue = { createValue() },
			}
        end

        return unpack(currentVal.value.memoizedValue)
    end
end