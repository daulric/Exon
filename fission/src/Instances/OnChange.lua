local logError = require(script.Parent.Parent:WaitForChild("Log").logError)

return function (property)
    local eventKey = {}
    eventKey.key = "SpecialKey"
    eventKey.kind = "OnChange"
    eventKey.stage = "observer"

    function eventKey:setup(propValue, instance: Instance, tempBin)

        local ok, event = pcall(instance.GetPropertyChangedSignal, instance, property)
		if not ok then
			logError("cannotConnectChange", nil, instance.ClassName, property)
		elseif typeof(propValue) ~= "function" then
			logError("invalidChangeHandler", nil, property)
		else
			table.insert(tempBin, event:Connect(function()
				propValue((instance :: any)[property])
			end))
		end
    end

    return eventKey

end