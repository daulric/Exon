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
	local inputTable = peek(self._inputTable)
	local outputValues = {}

	local didChange = false

	self._oldValueCache, self._valueCache = self._valueCache, self._oldValueCache
	local newValueCache = self._valueCache
	local oldValueCache = self._oldValueCache
	table.clear(newValueCache)

	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end

	self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet
	table.clear(self.dependencySet)

	if inputIsState then
		self._inputTable.dependentSet[self] = true
		self.dependencySet[self._inputTable] = true
	end

	for inKey, inValue in pairs(inputTable) do
		local oldCachedValues = oldValueCache[inValue]
		local shouldRecalculate = oldCachedValues == nil

		local value, valueData, meta

		if type(oldCachedValues) == "table" and #oldCachedValues > 0 then
			local valueInfo = table.remove(oldCachedValues, #oldCachedValues)
			value = valueInfo.value
			valueData = valueInfo.valueData
			meta = valueInfo.meta

			if #oldCachedValues <= 0 then
				oldValueCache[inValue] = nil
			end
		elseif oldCachedValues ~= nil then
			oldValueCache[inValue] = nil
			shouldRecalculate = true
		end

		if valueData == nil then
			valueData = {
				dependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				oldDependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				dependencyValues = setmetatable({}, WEAK_KEYS_METATABLE),
			}
		end

		if shouldRecalculate == false then
			for dependency, oldValue in pairs(valueData.dependencyValues) do
				if oldValue ~= peek(dependency) then
					shouldRecalculate = true
					break
				end
			end
		end

		if shouldRecalculate then
			valueData.oldDependencySet, valueData.dependencySet = valueData.dependencySet, valueData.oldDependencySet
			table.clear(valueData.dependencySet)

			local use = makeUseCallback(valueData.dependencySet)
			local processOK, err, newOutValue, newMetaValue = xpcall(self._processor, parseError, inValue, use)

			if processOK then
				if self._destructor == nil and (needsDestruction(newOutValue) or needsDestruction(newMetaValue)) then
					logWarn("destructorNeededForValues")
				end

				if value ~= nil then
					local destructOK, err = xpcall(self._destructor or cleanup, parseError, value, meta)
					if not destructOK then
						logErrorNonFatal("forValuesDestructorError", err)
					end
				end

				value = newOutValue
				meta = newMetaValue
				didChange = true
			else
				valueData.oldDependencySet, valueData.dependencySet = valueData.dependencySet, valueData.oldDependencySet
				logErrorNonFatal("forValuesProcessorError", err)
			end
		end

		local newCachedValues = newValueCache[inValue]
		if newCachedValues == nil then
			newCachedValues = {}
			newValueCache[inValue] = newCachedValues
		end

		table.insert(newCachedValues, {
			value = value,
			valueData = valueData,
			meta = meta,
		})

		outputValues[inKey] = value

		for dependency in pairs(valueData.dependencySet) do
			valueData.dependencyValues[dependency] = peek(dependency)

			self.dependencySet[dependency] = true
			dependency.dependentSet[self] = true
		end
	end

	for _oldInValue, oldCachedValueInfo in pairs(oldValueCache) do
		for _, valueInfo in ipairs(oldCachedValueInfo) do
			local oldValue = valueInfo.value
			local oldMetaValue = valueInfo.meta

			local destructOK, err = xpcall(self._destructor or cleanup, parseError, oldValue, oldMetaValue)
			if not destructOK then
				logErrorNonFatal("forValuesDestructorError", err)
			end

			didChange = true
		end

		table.clear(oldCachedValueInfo)
	end

	self._outputTable = outputValues

	return didChange
end

function class:_peek(): any
	return self._outputTable
end

function class:get()
	return self:_peek()
end

local function ForValues<VI, VO, M>(inputTable, processor: (VI) -> (VO, M?), destructor: (VO, M?) -> ()?)

	local inputIsState = isState(inputTable)

	local self = setmetatable({
		type = "State",
		kind = "ForValues",
		dependencySet = {},
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
		_oldDependencySet = {},

		_processor = processor,
		_destructor = destructor,
		_inputIsState = inputIsState,

		_inputTable = inputTable,
		_outputTable = {},
		_valueCache = {},
		_oldValueCache = {},
	}, CLASS_METATABLE)

	self:update()

	return self
end

return ForValues