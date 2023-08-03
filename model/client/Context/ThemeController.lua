local devbox = require(game.ReplicatedStorage.devbox)
local retract = devbox.retract

local Theme = require(script.Parent:WaitForChild("Theme"))
local Signal = script.Parent:WaitForChild("Signal")

local ThemeController = retract.Component:extend("ThemeController")

local foreground = Color3.fromRGB(255, 255, 255)
local background = Color3.fromRGB(0, 0, 0)

function ThemeController:init()
    self:setState({
        lastTheme = {},
        darkmode = true,

        theme = {
            background = background,
            foreground = foreground
        }
    })
end

function ThemeController:didMount()
    Signal.Event:Connect(function()

        self:setState(function(state)
            state.darkmode = not state.darkmode

            if state.darkmode == true then
                state.theme.background = background
                state.theme.foreground = foreground
            elseif state.darkmode == false then
                state.theme.background = foreground
                state.theme.foreground = background
            end

            return state
        end)

    end)
end

function ThemeController:render()
    return retract.createElement(Theme.Producer, {
        value = self.state.theme,
    }, self.props[retract.Children])
end

return ThemeController