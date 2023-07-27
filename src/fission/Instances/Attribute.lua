local ftypeof = require(script.Parent.Parent:WaitForChild("Tools").ftypeof)
local peek = require(script.Parent.Parent:WaitForChild("State").peek)
local Observer = require(script.Parent.Parent:WaitForChild("State").Observer)
local logError = require(script.Parent.Parent:WaitForChild("Log").logError)

local function setAttribute(instance: Instance, attribute: string, value: any)
    instance:SetAttribute(attribute, value)
end

local function bindAttribute(instance: Instance, attribute: string, value: any, cleanupTasks)
    if ftypeof(value) == "State" then
        local didDefer = false
        local function update()
            if not didDefer then
                didDefer = true
                    task.defer(function()
                    didDefer = false
                    setAttribute(instance, attribute, peek(value))
                end)
            end
        end
	    setAttribute(instance, attribute, peek(value))
	    table.insert(cleanupTasks, Observer(value :: any):onChange(update))
    else
        setAttribute(instance, attribute, value)
    end
end

local function Attribute(attributeName: string)
    local AttributeKey = {}
    AttributeKey.type = "SpecialKey"
    AttributeKey.kind = "Attribute"
    AttributeKey.stage = "self"

    if attributeName == nil then
        logError("attributeNameNil")
    end

    function AttributeKey:apply(attributeValue: any, applyTo: Instance, cleanupTasks)
        bindAttribute(applyTo, attributeName, attributeValue, cleanupTasks)
    end

    return AttributeKey
end

return Attribute