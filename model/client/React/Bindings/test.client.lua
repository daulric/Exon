local Players = game:GetService("Players")
local devbox = require(game.ReplicatedStorage.devbox)

local react = devbox.react
local testComp = require(script.Parent:WaitForChild("testComponent"))

local element = react.createElement("ScreenGui", {
    Name = "react Bindings",
    IgnoreGuiInset = true,
}, {
    TestComp = react.createElement(testComp)
})

local handle = react.mount(element, Players.LocalPlayer.PlayerGui)

task.wait(10)
handle = react.update(handle, react.createElement("ScreenGui", {
    Name = "react Bindings",
    IgnoreGuiInset = true,
}, {
    TestComp = react.createElement(testComp),
}))
print("Updating", script.Parent.Name, "react")