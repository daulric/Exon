local Players = game:GetService("Players")
local devbox = require(game.ReplicatedStorage.devbox)
local retract = devbox.retract

local ThemeController = require(script.Parent:WaitForChild("ThemeController"))
local Button = require(script.Parent:WaitForChild("Button"))

local handle

local element = retract.createElement(ThemeController, {}, {
    ScreenGui = retract.createElement("ScreenGui", {
        Name = "Retract Context",
        IgnoreGuiInset = true,
    }, {
        Button = retract.createElement(Button),
    })
})

handle = retract.mount(element, Players.LocalPlayer.PlayerGui)

task.wait(10)
handle = retract.update(handle, element)
print("Updating", script.Parent.Name, "Retract")