local devbox = require(game.ReplicatedStorage.devbox)
local retract = devbox.retract

local ThemeController = require(script.Parent:WaitForChild("ThemeController"))
local  Frame = require(script.Parent:WaitForChild("Frame"))

local Main = retract.Component:extend("Main")

local signal = script.Parent:WaitForChild("Signal")

local function chageColor()
    signal:Fire()
end

function Main:render()
    return retract.createElement(ThemeController, {}, {
        ScreenGui = retract.createElement("ScreenGui", {
            Name = "Theme Context",
            IgnoreGuiInset = true,
        }, {
            Frame = retract.createElement(Frame),
            Button = retract.createElement("TextButton", {
                Name = "Button",
                Position = UDim2.fromScale(0.6, 0.1),
                Size = UDim2.fromScale(0.1, 0.1),
                [retract.Event.Activated] = chageColor,
            })
        })
    })
end

return Main