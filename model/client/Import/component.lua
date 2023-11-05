local ReplicatedStorage = game:GetService("ReplicatedStorage")
local exon = require(ReplicatedStorage:WaitForChild("exon"))


local Component, createElement = exon.import(exon.react) {
    "Component", "createElement"
}

local test = Component:extend("test import")

function test:render()
    return createElement("TextLabel", {
        Name = "Component Import Working"
    })
end

return test