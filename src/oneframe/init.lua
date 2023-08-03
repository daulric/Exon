local Utilities = script:WaitForChild("Utilities")
local Tools = script:WaitForChild("Tools")
local Service = script:WaitForChild("Services")

local compile = require(Tools.compile)

local Framework = require(script:WaitForChild("Framework"))
local Component = require(script:WaitForChild("Component"))

local Promise = require(Tools:WaitForChild("Promise"))

local Services = {
	Input = require(Service:WaitForChild("Input")),
}

local Cleany = require(Utilities.Cleany)

local OneFrame = {
	-- Main Stuff
	Component = Component,
	Start = Framework,

	-- Services!
	Input = Services.Input,
	Promise = Promise,

	-- Utilites!
	createCleany = Cleany.create,
	Settings = require(script:WaitForChild("Settings"))
}

compile(OneFrame)

return OneFrame