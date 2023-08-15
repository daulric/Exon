local logError = require(script.Parent.Parent:WaitForChild("Log").logError)

return function (attribute)
    local eventKey = {}
    eventKey.key = "SpecialKey"
    eventKey.kind = "AttributeChange"
    eventKey.stage = "observer"

    function eventKey:setup(propValue, instance: Instance, tempBin)
        if typeof(propValue) ~= "function" then
			logError("invalidAttributeChangeHandler", nil, attribute)
		end
		local ok, event = pcall(instance.GetAttributeChangedSignal, instance, attribute)
		if not ok then
			logError("cannotConnectAttributeChange", nil, instance.ClassName, attribute)
		else
			propValue((instance :: any):GetAttribute(attribute))
			table.insert(tempBin, event:Connect(function()
				propValue((instance:: any):GetAttribute(attribute))
			end))
		end
    end

    return eventKey
end