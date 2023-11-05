local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local exon = require(ReplicatedStorage:WaitForChild("exon"))

local react = exon.react

local createElement, mount = exon.import(react) {
    "createElement",
    "mount"
}

local component = require(script.Parent:WaitForChild("component"))

local element = createElement("ScreenGui", {
    Name = "Import Test Working",
}, {
    TextLabel = createElement("TextLabel", {
        Name = "Import Test Label",
        TextScaled = true,
    }),

    Comp = createElement(component),
})

mount(element, Players.LocalPlayer.PlayerGui)