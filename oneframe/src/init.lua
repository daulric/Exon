local Tools = script:WaitForChild("Tools")

local compile = require(Tools.compile)

local Framework = require(script:WaitForChild("Framework"))
local Component = require(script:WaitForChild("Component"))

local Promise = require(Tools:WaitForChild("Promise"))

local OneFrame = {
	-- Main Stuff
	Component = Component,
	Start = Framework,

	-- Services!
	Promise = Promise,

	-- Utilites!
	Settings = require(script:WaitForChild("Settings"))
}

compile(OneFrame)

return OneFrame