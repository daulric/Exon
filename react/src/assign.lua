local function assign(target, ...)
	for index = 1, select("#", ...) do
		local source = select(index, ...)

		if source ~= nil then
			for key, value in pairs(source) do
				target[key] = value
			end
		end

	end

	return target
end

return assign