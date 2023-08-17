local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local devbox = require(ReplicatedStorage:WaitForChild("devbox"))

local react = devbox.react

local createElement, mount = devbox.import(react) {
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