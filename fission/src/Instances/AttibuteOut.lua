local ftypeof = require(script.Parent.Parent:WaitForChild("Tools").ftypeof)
local logError = require(script.Parent.Parent:WaitForChild("Log").logError)

local function AttributeOut(attributeName: string)
	local attributeOutKey = {}
	attributeOutKey.type = "SpecialKey"
	attributeOutKey.kind = "AttributeOut"
	attributeOutKey.stage = "observer"

	function attributeOutKey:apply(stateObject, applyTo: Instance, cleanupTasks)
		if ftypeof(stateObject) ~= "State" or stateObject.kind ~= "Value" then
			logError("invalidAttributeOutType")
		end
		if attributeName == nil then
			logError("attributeNameNil")
		end
		local ok, event = pcall(applyTo.GetAttributeChangedSignal, applyTo, attributeName)
		if not ok then
			logError("invalidOutAttributeName", applyTo.ClassName, attributeName)
		else
			stateObject:set((applyTo :: any):GetAttribute(attributeName))

			table.insert(cleanupTasks, event:Connect(function()	
				stateObject:set((applyTo :: any):GetAttribute(attributeName))
			end))

			table.insert(cleanupTasks, function()
				stateObject:set(nil)
			end)
		end
	end

	return attributeOutKey
end

return AttributeOut