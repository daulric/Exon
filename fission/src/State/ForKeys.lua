local Packages = script.Parent.Parent

local Log = Packages:WaitForChild("Log")
local State = Packages:WaitForChild("State")
local Tools = Packages:WaitForChild("Tools")

local logError = require(Log:WaitForChild("logError"))
local logErrorNonFatal = require(Log:WaitForChild("logErrorNonFatal"))
local logWarn = require(Log:WaitForChild("logWarn"))
local parseError = require(Log:WaitForChild("parseError"))

local peek = require(State:WaitForChild("peek"))
local makeUseCallback = require(State:WaitForChild("makeUseCallback"))
local isState = require(State:WaitForChild("isState"))

local needsDestruction = require(Tools:WaitForChild("needsDestruction"))
local cleanup = require(Tools:WaitForChild("cleanup"))

local class = {}

local CLASS_METATABLE = {__index = class}
local WEAK_KEYS_METATABLE = {__mode = "k"}

function class:update(): boolean
	local inputIsState = self._inputIsState
	local newInputTable = peek(self._inputTable)
	local oldInputTable = self._oldInputTable
	local outputTable = self._outputTable

	local keyOIMap = self._keyOIMap
	local keyIOMap = self._keyIOMap
	local meta = self._meta

	local didChange = false

	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end

	self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet
	table.clear(self.dependencySet)

	if inputIsState then
		self._inputTable.dependentSet[self] = true
		self.dependencySet[self._inputTable] = true
	end

	for newInKey, value in pairs(newInputTable) do

		local keyData = self._keyData[newInKey]

		if keyData == nil then
			keyData = {
				dependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				oldDependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				dependencyValues = setmetatable({}, WEAK_KEYS_METATABLE),
			}
			self._keyData[newInKey] = keyData
		end

		local shouldRecheck = oldInputTable[newInKey] == nil

		if shouldRecheck == false then
			for dependency, oldValue in pairs(keyData.dependencyValues) do
				if oldValue ~= peek(dependency) then
					shouldRecheck = true
					break
				end
			end
		end

		if shouldRecheck then
			keyData.oldDependencySet, keyData.dependencySet = keyData.dependencySet, keyData.oldDependencySet
			table.clear(keyData.dependencySet)

			local use = makeUseCallback(keyData.dependencySet)
			local processOK, newOutKey, newMetaValue = xpcall(self._processor, parseError, newInKey, use)

			if processOK then
				if self._destructor == nil and (needsDestruction(newOutKey) or needsDestruction(newMetaValue)) then
					logWarn("destructorNeededForKeys")
				end

				local oldInKey = keyOIMap[newOutKey]
				local oldOutKey = keyIOMap[newInKey]

				if oldInKey ~= newInKey and newInputTable[oldInKey] ~= nil then
					logError("forKeysKeyCollision", nil, tostring(newOutKey), tostring(oldInKey), tostring(newOutKey))
				end

				if oldOutKey ~= newOutKey and keyOIMap[oldOutKey] == newInKey then

					local oldMetaValue = meta[oldOutKey]

					local destructOK, err = xpcall(self._destructor or cleanup, parseError, oldOutKey, oldMetaValue)
					if not destructOK then
						logErrorNonFatal("forKeysDestructorError", err)
					end

					keyOIMap[oldOutKey] = nil
					outputTable[oldOutKey] = nil
					meta[oldOutKey] = nil
				end

				oldInputTable[newInKey] = value
				meta[newOutKey] = newMetaValue
				keyOIMap[newOutKey] = newInKey
				keyIOMap[newInKey] = newOutKey
				outputTable[newOutKey] = value

				didChange = true
			else
				keyData.oldDependencySet, keyData.dependencySet = keyData.dependencySet, keyData.oldDependencySet

				logErrorNonFatal("forKeysProcessorError", newOutKey)
			end
		end

		for dependency in pairs(keyData.dependencySet) do
			keyData.dependencyValues[dependency] = peek(dependency)

			self.dependencySet[dependency] = true
			dependency.dependentSet[self] = true
		end
	end

	for outputKey, inputKey in pairs(keyOIMap) do
		if newInputTable[inputKey] == nil then

			local oldMetaValue = meta[outputKey]

			local destructOK, err = xpcall(self._destructor or cleanup, parseError, outputKey, oldMetaValue)
			if not destructOK then
				logErrorNonFatal("forKeysDestructorError", err)
			end

			oldInputTable[inputKey] = nil
			meta[outputKey] = nil
			keyOIMap[outputKey] = nil
			keyIOMap[inputKey] = nil
			outputTable[outputKey] = nil
			self._keyData[inputKey] = nil

			didChange = true
		end
	end

	return didChange
end

function class:_peek(): any
	return self._outputTable
end

function class:get()
	return self:_peek()
end

local function ForKeys<KI, KO, M>(inputTable, processor: (KI) -> (KO, M?), destructor: (KO, M?) -> ()?)

	local inputIsState = isState(inputTable)

	local self = setmetatable({
		type = "State",
		kind = "ForKeys",
		dependencySet = {},
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
		_oldDependencySet = {},

		_processor = processor,
		_destructor = destructor,
		_inputIsState = inputIsState,

		_inputTable = inputTable,
		_oldInputTable = {},
		_outputTable = {},
		_keyOIMap = {},
		_keyIOMap = {},
		_keyData = {},
		_meta = {},
	}, CLASS_METATABLE)

	self:update()

	return self
end

return ForKeys