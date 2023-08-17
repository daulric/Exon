local ReplicatedStorage = game:GetService("ReplicatedStorage")
local devbox = require(ReplicatedStorage:WaitForChild("devbox"))


local Component, createElement = devbox.import(devbox.react) {
    "Component", "createElement"
}

local test = Component:extend("test import")

function test:render()
    return createElement("TextLabel", {
        Name = "Component Import Working"
    })
end

return test