local Tools = script.Parent.Parent:WaitForChild("Tools")
local State = script.Parent.Parent:WaitForChild("State")
local Log = script.Parent.Parent:WaitForChild("Log")

local isState = require(State:WaitForChild("isState"))
local peek = require(State:WaitForChild("peek"))
local Observer = require(State:WaitForChild("Observer"))

local logWarn = require(Log:WaitForChild("logWarn"))

local ftypeof = require(Tools:WaitForChild("ftypeof"))

local EXPERIMENTAL_AUTO_NAMING = false

local Children = {}
Children.key = "SpecialKey"
Children.kind = "Children"
Children.stage = "descendants"

function Children:setup(propValue, applyTo: Instance, cleanupTasks)
    local newParented = {}
	local oldParented = {}

	local newDisconnects = {}
	local oldDisconnects = {}

	local updateQueued = false
	local queueUpdate: () -> ()

	local function updateChildren()
		if not updateQueued then
			return
		end
		updateQueued = false

		oldParented, newParented = newParented, oldParented
		oldDisconnects, newDisconnects = newDisconnects, oldDisconnects
		table.clear(newParented)
		table.clear(newDisconnects)

		local function processChild(child: any, autoName: string?)
			local childType = typeof(child)

			if childType == "Instance" then

				newParented[child] = true
				if oldParented[child] == nil then
					child.Parent = applyTo
				else
					oldParented[child] = nil
				end

				if EXPERIMENTAL_AUTO_NAMING and autoName ~= nil then
					child.Name = autoName
				end

			elseif isState(child) then

				local value = peek(child)

				if value ~= nil then
					processChild(value, autoName)
				end

				local disconnect = oldDisconnects[child]
				if disconnect == nil then
					disconnect = Observer(child):onChange(queueUpdate)
				else
					oldDisconnects[child] = nil
				end

				newDisconnects[child] = disconnect

			elseif childType == "table" then

				for key, subChild in pairs(child) do
					local keyType = typeof(key)
					local subAutoName: string? = nil

					if keyType == "string" then
						subAutoName = key
					elseif keyType == "number" and autoName ~= nil then
						subAutoName = autoName .. "_" .. key
					end

					processChild(subChild, subAutoName)
				end

			else
				logWarn("unrecognisedChildType", childType)
			end
		end

		if propValue ~= nil then
			processChild(propValue)
		end

		for oldInstance in pairs(oldParented) do
			oldInstance.Parent = nil
		end

		for oldState, disconnect in pairs(oldDisconnects) do
			disconnect()
		end
	end

	queueUpdate = function()
		if not updateQueued then
			updateQueued = true
			task.defer(updateChildren)
		end
	end

	table.insert(cleanupTasks, function()
		propValue = nil
		updateQueued = true
		updateChildren()
	end)

	updateQueued = true
	updateChildren()
end

return Children