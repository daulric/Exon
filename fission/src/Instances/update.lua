local applyProps = require(script.Parent:WaitForChild("applyProps"))

return function (instance: Instance)
    return function (props)
        applyProps(instance, props)
        return instance
    end
end