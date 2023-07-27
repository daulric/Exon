local Packages = script.Parent.Parent

local State = Packages:WaitForChild("State")
local Tools = Packages:WaitForChild("Tools")
local Log = Packages:WaitForChild("Log")

local parseError = require(Log:WaitForChild("parseError"))
local logError = require(Log:WaitForChild("logError"))
local logWarn = require(Log:WaitForChild("logWarn"))
local logErrorNonFatal  = require(Log:WaitForChild("logErrorNonFatal"))

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

	self._oldOutputTable, self._outputTable = self._outputTable, self._oldOutputTable

	local oldOutputTable = self._oldOutputTable
	local newOutputTable = self._outputTable
	table.clear(newOutputTable)

	for newInKey, newInValue in pairs(newInputTable) do

		local keyData = self._keyData[newInKey]

		if keyData == nil then
			keyData = {
				dependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				oldDependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				dependencyValues = setmetatable({}, WEAK_KEYS_METATABLE),
			}
			self._keyData[newInKey] = keyData
		end

		local shouldRecheck = oldInputTable[newInKey] ~= newInValue

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
			local processOK, newOutKey, newOutValue, newMetaValue = xpcall(
				self._processor, parseError, newInKey, newInValue, use
			)

			if processOK then
				if self._destructor == nil and (needsDestruction(newOutKey) or needsDestruction(newOutValue) or needsDestruction(newMetaValue)) then
					logWarn("destructorNeededForPairs")
				end

				if newOutputTable[newOutKey] ~= nil then

					local previousNewKey, previousNewValue
					for inKey, outKey in pairs(keyIOMap) do
						if outKey == newOutKey then
							previousNewValue = newInputTable[inKey]
							if previousNewValue ~= nil then
								previousNewKey = inKey
								break
							end
						end
					end

					if previousNewKey ~= nil then
						logError(
							"forPairsKeyCollision",
							nil,
							tostring(newOutKey),
							tostring(previousNewKey),
							tostring(previousNewValue),
							tostring(newInKey),
							tostring(newInValue)
						)
					end
				end

				local oldOutValue = oldOutputTable[newOutKey]

				if oldOutValue ~= newOutValue then
					local oldMetaValue = meta[newOutKey]
					if oldOutValue ~= nil then
						local destructOK, err = xpcall(self._destructor or cleanup, parseError, newOutKey, oldOutValue, oldMetaValue)
						if not destructOK then
							logErrorNonFatal("forPairsDestructorError", err)
						end
					end

					oldOutputTable[newOutKey] = nil
				end

				oldInputTable[newInKey] = newInValue
				keyIOMap[newInKey] = newOutKey
				meta[newOutKey] = newMetaValue
				newOutputTable[newOutKey] = newOutValue

				didChange = true
			else

				keyData.oldDependencySet, keyData.dependencySet = keyData.dependencySet, keyData.oldDependencySet

				logErrorNonFatal("forPairsProcessorError", newOutKey)
			end
		else
			local storedOutKey = keyIOMap[newInKey]

			if newOutputTable[storedOutKey] ~= nil then

				local previousNewKey, previousNewValue
				for inKey, outKey in pairs(keyIOMap) do
					if storedOutKey == outKey then
						previousNewValue = newInputTable[inKey]

						if previousNewValue ~= nil then
							previousNewKey = inKey
							break
						end
					end
				end

				if previousNewKey ~= nil then
					logError(
						"forPairsKeyCollision",
						nil,
						tostring(storedOutKey),
						tostring(previousNewKey),
						tostring(previousNewValue),
						tostring(newInKey),
						tostring(newInValue)
					)
				end
			end

			newOutputTable[storedOutKey] = oldOutputTable[storedOutKey]
		end

		for dependency in pairs(keyData.dependencySet) do
			keyData.dependencyValues[dependency] = peek(dependency)

			self.dependencySet[dependency] = true
			dependency.dependentSet[self] = true
		end
	end

	for oldOutKey, oldOutValue in pairs(oldOutputTable) do

		if newOutputTable[oldOutKey] ~= oldOutValue then

			local oldMetaValue = meta[oldOutKey]
			if oldOutValue ~= nil then
				local destructOK, err = xpcall(self._destructor or cleanup, parseError, oldOutKey, oldOutValue, oldMetaValue)
				if not destructOK then
					logErrorNonFatal("forPairsDestructorError", err)
				end
			end

			if newOutputTable[oldOutKey] == nil then
				meta[oldOutKey] = nil
				self._keyData[oldOutKey] = nil
			end

			didChange = true
		end
	end

	for key in pairs(oldInputTable) do
		if newInputTable[key] == nil then
			oldInputTable[key] = nil
			keyIOMap[key] = nil
		end
	end

	return didChange
end

function class:_peek()
    return self._outputTable
end

function class:get()
    return self:_peek()
end

function ForPairs(inputTable, processor, destructor)
    local inputIsState = isState(inputTable)

	local self = setmetatable({
		key = "State",
		kind = "ForPairs",
		dependencySet = {},
		-- if we held strong references to the dependents, then they wouldn't be
		-- able to get garbage collected when they fall out of scope
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
		_oldDependencySet = {},

		_processor = processor,
		_destructor = destructor,
		_inputIsState = inputIsState,

		_inputTable = inputTable,
		_oldInputTable = {},
		_outputTable = {},
		_oldOutputTable = {},
		_keyIOMap = {},
		_keyData = {},
		_meta = {},
	}, CLASS_METATABLE)

	self:update()
	return self
end

return ForPairs