local NONE = {}

function extractValue(callbackOrvalue, currentValue)
    if type(callbackOrvalue) == "function" then
        callbackOrvalue(currentValue)
    else
        return callbackOrvalue
    end
end

return function(component)
    local setValues = {}

    return function (defaultValue)
        component.hookCounter += 1

        local hookCount = component.hookCounter
        local value = component.state[hookCount]

        if value == nil then
            local storedValue = component.defaultStateValues[hookCount]
            
            if storedValue == NONE then
                value = nil
            elseif storedValue ~= nil then
                value = storedValue
            elseif type(storedValue) == "function" then
                value = storedValue()

                if value == nil then
                   component.defaultStateValues[hookCount] = NONE
                else
                    component.defaultStateValues[hookCount] = value 
                end
            else
                value = defaultValue
                component.defaultStateValues[hookCount] = value
            end
        elseif value == NONE then
            value = nil
        end

        local setValue = setValues[hookCount]

        if setValue == nil then
            setValue = function(newValue)
                local currentVal = component.state[hookCount]

                if currentVal == nil then
                    currentVal = component.defaultStateValues[hookCount]
                end

                if currentVal == NONE then
                    currentVal = nil
                end

                newValue = extractValue(newValue, currentVal)

                if newValue == nil then
                    newValue = NONE
                end

                component:setState({
                    [hookCount] = newValue
                })

            end

        end

        return value, setValue
    end
end