local logError = require(script.Parent.Parent:WaitForChild("Log").logError)

local function getProperty_unsafe(instance: Instance, property: string)
	return (instance :: any)[property]
end

return function (eventname)
    local eventKey = {}
    eventKey.key = "SpecialKey"
    eventKey.kind = "Event"
    eventKey.stage = "observer"

    function eventKey:setup(callback, instance, tempBin)
        local ok, event = pcall(getProperty_unsafe, instance, eventname)

		if not ok or typeof(event) ~= "RBXScriptSignal" then
			logError("cannotConnectEvent", nil, instance.ClassName, eventname)
		elseif typeof(callback) ~= "function" then
			logError("invalidEventHandler", nil, eventname)
		else
			table.insert(tempBin, event:Connect(callback))
		end
        
    end

    return eventKey
end