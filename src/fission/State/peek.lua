local isState = require(script.Parent:WaitForChild("isState"))

local function peek(data)
    if isState(data) then
        return data:_peek()
    else
        return data
    end
end

return peek