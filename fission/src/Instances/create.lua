local applyProps = require(script.Parent:WaitForChild("applyProps"))
local logError = require(script.Parent.Parent:WaitForChild("Log").logError)

return function (class: string)
    return function (props)
        local ok, instance = pcall(function()
			return Instance.new(class) :: Instance
		end)

		if not ok then
			logError("cannotCreateClass", nil, class)
		end

		applyProps(props, instance)

		return instance
    end
end