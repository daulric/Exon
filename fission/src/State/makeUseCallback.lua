local isState = require(script.Parent:WaitForChild("isState"))

local function makeUseCallback(dependencySet)
    local function use(data)
        if isState(data) then
            dependencySet[data] = true
            return (data):_peek()
        else
            return data
        end
    end

    return use
end

return makeUseCallback