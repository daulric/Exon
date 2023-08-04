local devbox = require(game.ReplicatedStorage.devbox)
local retract = devbox.retract

local Theme = require(script.Parent:WaitForChild("Theme"))

return function (props)
    return retract.createElement(Theme.Consumer, {
        render = function(theme)
            return retract.createElement("Frame", {
                Name = "Context Frame",
                Size = UDim2.fromScale(0.5, 0.5),
                BackgroundColor3 = theme.background
            }, {
                Text = retract.createElement("TextLabel", {
                    Size = UDim2.fromScale(0.4, 0.3),
                    Position = UDim2.new(0.5, 0, 0.5,0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    TextColor3 = theme.foreground,
                    BackgroundTransparency = 1,
                    TextScaled = true,
                })
            })
        end
    })
end