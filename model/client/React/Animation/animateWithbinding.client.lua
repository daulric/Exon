local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local testComp = require(script.Parent:WaitForChild("testcomp"))

local devbox = require(ReplicatedStorage:WaitForChild("devbox"))
local react = devbox.react

local element = react.createElement("ScreenGui", {
    Name = "React Animate Test",
    IgnoreGuiInset = true,
}, {
    Animate = react.createElement(testComp)
})

react.mount(element, Players.LocalPlayer.PlayerGui)
print("Animate Running!")