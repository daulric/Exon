local Framework = require(script:WaitForChild("Framework"))
local Component = require(script:WaitForChild("Component"))

local compile = require(script:WaitForChild("freeze"))

local OneFrame = {
    OnStart = Framework,
    Component = Component,
}

compile(OneFrame, "OneFrame")
return OneFrame