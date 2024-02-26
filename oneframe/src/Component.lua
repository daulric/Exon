local Component = {}
Component.__index = Component

local tidy = require(script.Parent:WaitForChild("tidy"))

local Marker = require(script.Parent:WaitForChild("Mark"))
local msgTag = "[Exon OneFrame]:"

function Component.create(name)
    local class = setmetatable({
        name = name,
        cleanup = tidy.init(),
        [Marker] = { test = false }
    }, Component)

    setmetatable(class, Component)
    return class
end

function Component:start()
    warn(`{msgTag} Must have a Start Function; {self.name}`)
    return
end

function Component:SetTestMode()
    self[Marker].test = true
end

return Component