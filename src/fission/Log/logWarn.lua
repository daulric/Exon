local messages = require(script.Parent:WaitForChild("messages"))

local function logWarn(messageID, ...)
	local formatString: string

	if messages[messageID] ~= nil then
		formatString = messages[messageID]
	else
		messageID = "unknownMessage"
		formatString = messages[messageID]
	end

	warn(string.format("[Fission] " .. formatString .. "\n(ID: " .. messageID .. ")", ...))
end

return logWarn