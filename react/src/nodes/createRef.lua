local Binding = require(script.Parent.Parent:WaitForChild("Binding"))

function createRef()
    local bind, _ = Binding.create(nil)

    local ref = {}

    setmetatable(ref, {
        __index = function(_self, key)
			if key == "value" then
				return bind:getValue()
			else
				return bind[key]
			end
		end,
		__newindex = function(_self, key, value)
			if key == "current" then
				error("Cannot assign to the 'current' property of refs", 2)
			end

			bind[key] = value
		end,
		__tostring = function(_self)
			return ("react.Ref(%s)"):format(tostring(bind:getValue()))
		end,
    })

    return ref

end

return createRef