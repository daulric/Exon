local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local testComp = require(script.Parent:WaitForChild("testcomp"))

local exon = require(ReplicatedStorage:WaitForChild("exon"))
local react = exon.react

local element = react.createElement("ScreenGui", {
    Name = "React Animate Test",
    IgnoreGuiInset = true,
}, {
    Animate = react.createElement(testComp)
})

react.mount(element, Players.LocalPlayer.PlayerGui)
print("Animate Running!")