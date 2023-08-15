local Packages = script.Parent.Parent

local Log = Packages:WaitForChild("Log")
local Tools = Packages:WaitForChild("Tools")
local State = Packages:WaitForChild("State")

local logError = require(Log:WaitForChild("logError"))
local logErrorNonFatal = require(Log:WaitForChild("logErrorNonFatal"))
local logWarn = require(Log:WaitForChild("logWarn"))
local parseError = require(Log:WaitForChild("parseError"))

local isSimilar = require(Tools:WaitForChild("isSimilar"))
local needsDestruction = require(Tools:WaitForChild("needsDestruction"))
local makeUseCallback = require(State:WaitForChild("makeUseCallback"))

local class = {}

local CLASS_METATABLE = {__index = class}
local WEAK_KEYS_METATABLE = {__mode = "k"}

function class:update(): boolean

	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end

	self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet
	table.clear(self.dependencySet)

	local use = makeUseCallback(self.dependencySet)
	local ok, newValue, newMetaValue = xpcall(self._processor, parseError, use)

	if ok then
		if self._destructor == nil and needsDestruction(newValue) then
			logWarn("destructorNeededComputed")
		end

		if newMetaValue ~= nil then
			logWarn("multiReturnComputed")
		end

		local oldValue = self._value
		local similar = isSimilar(oldValue, newValue)
		if self._destructor ~= nil then
			self._destructor(oldValue)
		end
		self._value = newValue

		for dependency in pairs(self.dependencySet) do
			dependency.dependentSet[self] = true
		end

		return not similar
	else

		logErrorNonFatal("computedCallbackError", newValue)

		self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet

		for dependency in pairs(self.dependencySet) do
			dependency.dependentSet[self] = true
		end

		return false
	end
end

function class:_peek()
	return self._value
end

function class:get()
	return self:_peek()
end

local function Computed<T>(processor: () -> T, destructor: ((T) -> ())?)
	local dependencySet = {}

	local self = setmetatable({
		type = "State",
		kind = "Computed",
		dependencySet = dependencySet,
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
		_oldDependencySet = {},
		_processor = processor,
		_destructor = destructor,
		_value = nil
	}, CLASS_METATABLE)

	self:update()

	return self
end

return Computed