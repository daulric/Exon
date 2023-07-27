function compile(data: { [any]: any})
	data.Success = false
	
	local success, completed = pcall(function()
		local Name = tostring(data)

		return setmetatable(data, {
			__index = function(_self, key)
				local message = ("%q (%s) is not a valid member of %s"):format(tostring(key), typeof(key), Name)

				error(message, 2)
			end,

			__newindex = function(_self, key, _value)
				local message = ("%q (%s) is not a valid member of %s"):format(tostring(key), typeof(key), Name)

				error(message, 2)
			end,
		})
	end)
	
	if success then
		return completed
	else
		warn(`{data} couldn't be compiled! try again!`)
	end
	
end

return compile
