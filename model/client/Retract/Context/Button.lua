local devbox = require(game.ReplicatedStorage.devbox)
local retract = devbox.retract

local Theme = require(script.Parent:WaitForChild("Theme"))

local signal = script.Parent:WaitForChild("Signal")

return function (props)
    return retract.createElement(Theme.Consumer, {
        render = function(theme)
            return retract.createElement("TextButton", {
                Name = "Context Frame",
                Size = UDim2.fromScale(0.5, 0.5),
                BackgroundColor3 = theme.background,
                Text = "Click To Change Theme!",
                TextScaled = true,
                TextColor3 = theme.foreground,

                [retract.Event.MouseButton1Click] = function()
                    signal:Fire()
                end
            })
        end
    })
end