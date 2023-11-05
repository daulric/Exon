local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local exon = require(ReplicatedStorage:WaitForChild("exon"))

local react = exon.react

local testComp = react.Component:extend("test comp")

function testComp:init()
    
end

function testComp:didMount()
    local tinfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true, 0)

    local new = TweenService:Create(self.textlabel, tinfo, {
        BackgroundTransparency = 1,
        TextTransparency = 1,
    })

    new.Completed:Connect(function(playbackState)
        task.wait(2)
        new:Play()
    end)

    new:Play()
end

function testComp:render()
    return react.createElement("TextLabel", {
        [react.Ref] = function(instance: TextLabel)
            self.textlabel = instance
        end,
        Name = "React Animation Test",
        BackgroundTransparency = 0,
        Text = "Item is Animating!",
        TextTransparency = 0,
        TextScaled = true,
        Size = UDim2.new(1,0,1,0),
    })
end

return testComp