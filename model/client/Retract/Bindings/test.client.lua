local Players = game:GetService("Players")
local devbox = require(game.ReplicatedStorage.devbox)

local retract = devbox.retract
local testComp = require(script.Parent:WaitForChild("testComponent"))

local element = retract.createElement("ScreenGui", {
    Name = "Retract Bindings",
    IgnoreGuiInset = true,
}, {
    TestComp = retract.createElement(testComp)
})

local handle = retract.mount(element, Players.LocalPlayer.PlayerGui)

task.wait(10)
handle = retract.update(handle, retract.createElement("ScreenGui", {
    Name = "Retract Bindings",
    IgnoreGuiInset = true,
}, {
    TestComp = retract.createElement(testComp),
}))
print("Updating", script.Parent.Name, "Retract")