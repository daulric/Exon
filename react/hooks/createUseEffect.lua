return function(component)
    return function (callback, dependOn)
        assert(type(callback) == "function", "`useEffect` does not have a function")

        component.hookCounter += 1
        local hookCount = component.hookCounter

        component.effects[hookCount] = {callback, dependOn}
    end
    
end