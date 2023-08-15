return function (component, useEffect, useState, useMemo)

    local fakeConsumer = setmetatable({}, {
		__index = component,
	})

	return function(context)
		local defaultValue = useMemo(function()
			local initialValue

			fakeConsumer.props = {
				render = function(value)
					initialValue = value
				end,
			}

			context.Consumer.render(fakeConsumer)
			return initialValue
		end, {})

		context.Consumer.init(fakeConsumer)

		local contextEntry = fakeConsumer.contextEntry

		local value, setValue = useState(
            if contextEntry == nil then
                defaultValue
            else
                contextEntry.value
            )

		useEffect(function()
			if contextEntry == nil then

				if value ~= defaultValue then
					setValue(defaultValue)
				end

				return
			end

			if value ~= contextEntry.value then
				setValue(contextEntry.value)
			end

			return contextEntry.onUpdate:Connect(setValue)
		end, { contextEntry })

		return value
	end
end