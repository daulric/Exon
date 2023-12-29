local Component = {}
Component.__index = Component

local Tools = script.Parent:WaitForChild("Tools")

local Symbol = require(Tools:WaitForChild("Symbol"))

-- Different Class
local LiveClass = {}
local TestClass = {}

local tidy = require(script.Parent:WaitForChild("tidy"))

type RegisterType = "live" | "test" | "shared"

function CheckId(Table: {[string]: any}, name: string)
	if Table[name] then
		return true
	end
end

function Component:extend(name: string, test: boolean?)

	local class = {}

	assert(
		CheckId(LiveClass, name) == nil or
		CheckId(TestClass, name) == nil,
		`{name} already exsist in execution table`
	)

	class.state = {}
	table.freeze(class.state)

	class.Cleanup = tidy.init()
	class.name = tostring(name)
	class.validation = Symbol.assign(`{name} .. Component`)

	if test then
		class.test = true
		TestClass[tostring(name)] = class
	else
		class.live = true
		LiveClass[tostring(name)] = class
	end

	setmetatable(class, Component)
	return class

end

function Component:start()
	error(`{self.name} does not have a start function`)
end

function Component:preload()
	-- Noop to contain the class when using self.
end

function Component:closing()
	-- Noop to contain the class when using self.
end

function Component:setState(value: any)

	assert(self.state, "there is no state to this component")
	assert(table.isfrozen(self.state) or self.state.isState, `this table is not properly set! {self.state}`)

	local NewClassState = table.clone(self.state)

	if type(value) == "table" then
		for index, stuff in pairs(value) do
			NewClassState[tostring(index)] = stuff
		end
	elseif type(value) == "function" then
		local newState = value(NewClassState)

		if type(newState) == "table" then 
			for index, stuff in pairs(newState) do
				NewClassState[tostring(index)] = stuff
			end
		else
			table.insert(NewClassState, value)
		end
	end

	NewClassState.isState = true
	self.state = NewClassState
	table.freeze(self.state)
end

function Component:GetComponent(name: string)
	if not name then
		return
	end
	
	if LiveClass[name] then
		return LiveClass[name]
	end

	if TestClass[name] then
		return TestClass[name]
	end

end

function Component:GetComponents()
	local Modules = {
		Test = TestClass,
		Live = LiveClass,
	}

	local compiled = table.freeze(table.clone(Modules))

	return compiled
	
end


export type Component = typeof(Component)

return Component