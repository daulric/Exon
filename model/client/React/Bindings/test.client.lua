local Players = game:GetService("Players")
local exon = require(game.ReplicatedStorage.exon)

local react = exon.react
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