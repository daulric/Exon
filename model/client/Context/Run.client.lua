local Players = game:GetService("Players")
local devbox = require(game.ReplicatedStorage.devbox)
local retract = devbox.retract

local Main = require(script.Parent:WaitForChild("main"))

retract.mount(retract.createElement(Main), Players.LocalPlayer.PlayerGui)