local devbox = require(game.ReplicatedStorage.devbox)
local retract = devbox.retract

local testComp = retract.Component:extend("Test For Bindings")

function testComp:init()
    self.textRef, self.updateCount = retract.createBinding(0)
end

function testComp:didMount()
    local value = self.textRef:getValue()
    print("Value is:", value)
end

function testComp:render()
    return retract.createElement("TextButton", {
        Name = "Binding Button",
        Position = UDim2.new(0.5, 0, 0.5, 0),

        Text = self.textRef:map(function(value)
            return "Types : "..tostring(value)
        end),
        [retract.Event.MouseButton1Click] = function()
            self.updateCount(self.textRef:getValue() + 1)
        end,

        Size = UDim2.new(0.5, 0, 0.5, 0),
    })
end

return testComp