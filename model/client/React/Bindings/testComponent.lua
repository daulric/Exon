local exon = require(game.ReplicatedStorage.exon)
local react = exon.react

local testComp = react.Component:extend("Test For Bindings")

function testComp:init()
    self.textRef, self.updateCount = react.createBinding(0)
end

function testComp:didMount()
    local value = self.textRef:getValue()
    print("Value is:", value)
end

function testComp:render()
    return react.createElement("TextButton", {
        Name = "Binding Button",
        Position = UDim2.new(0.5, 0, 0.5, 0),

        Text = self.textRef:map(function(value)
            return "Types : "..tostring(value)
        end),
        [react.Event.MouseButton1Click] = function()
            self.updateCount(self.textRef:getValue() + 1)
        end,

        Size = UDim2.new(0.5, 0, 0.5, 0),
    })
end

return testComp