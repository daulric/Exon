return function (component)
    return function (defaultVal)
        component.hookCounter += 1
        local hookCount = component.hookCounter

        if component.values == nil then
           component.values = {}
        end

        if component.values[hookCount] == nil then
            component.values[hookCount] = {value = defaultVal}
        end

        return component.values[hookCount]
    end
end