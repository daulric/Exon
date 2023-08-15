local Ref = {}
Ref.key = "SpecialKey"
Ref.kind = "Ref"
Ref.stage = "observer"

local logError = require(script.Parent.Parent:WaitForChild("Log").logError)
local ftypeof = require(script.Parent.Parent:WaitForChild("Tools").ftypeof)

function Ref:apply(refState: any, applyTo: Instance, tempBin)
	if ftypeof(refState) ~= "State" or refState.kind ~= "Value" then
		logError("invalidRefType")
	else
		refState:set(applyTo)
		table.insert(tempBin, function()
			refState:set(nil)
		end)
	end
end

return Ref