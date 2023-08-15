local Tools = script.Parent.Parent:WaitForChild("Tools")
local State = script.Parent.Parent:WaitForChild("State")
local Log = script.Parent.Parent:WaitForChild("Log")

local ftypeof = require(Tools:WaitForChild("ftypeof"))
local peek = require(script.Parent.Parent:WaitForChild("State"):WaitForChild("peek"))

local logError = require(Log:WaitForChild("logError"))

local cleanup = require(Tools:WaitForChild("cleanup"))

local Observer = require(State:WaitForChild("Observer"))

local function setProperty_check(instance: Instance, property: string, value: any)
    (instance:: any)[property] = value
end

local function assignTestProperty(instance: Instance, property: string)
    (instance :: any)[property] = (instance :: any)[property]
end

local function setProperty(instance: Instance, property: string, value: any)
    if not pcall(setProperty_check, instance, property, value) then
        if not pcall(assignTestProperty, instance, property) then
            if instance == nil then
                logError("setPropertyNilRef", nil, property, tostring(value))
            else
                logError("cannotAssignProperty", nil, instance.ClassName, property)
            end

        else
            local givenType = typeof(value)
            local expectedType = typeof((instance::any)[property])
            logError("invalidPropertyType", nil, instance.ClassName, property, expectedType, givenType)
        end
    end
end

local function bindProperty(instance: Instance, property: string, value: any, tempBin)
    if ftypeof(value) == "State" then
        local willUpdate = false

        local function updateLater()
            if willUpdate == false then
                willUpdate = true
                task.defer(function()
                    willUpdate = false
                    setProperty(instance, property, peek(value))
                end)
            end
        end

        setProperty(instance, property, peek(value))
        tempBin:Add(Observer(value :: any):onChange(updateLater))
    else
        setProperty(instance, property, value)
    end
end

local function applyProps(props, applyTo: Instance)
    local specialKeys = {
		self = {},
		descendants = {},
		ancestor = {},
		observer = {},
	}
	local cleanupTasks = {}

	for key, value in pairs(props) do
		local keyType = ftypeof(key)

		if keyType == "string" then
			if key ~= "Parent" then
				bindProperty(applyTo, key :: string, value, cleanupTasks)
			end
		elseif keyType == "SpecialKey" then
			local stage = (key).stage
			local keys = specialKeys[stage]
			if keys == nil then
				logError("unrecognisedPropertyStage", nil, stage)
			else
				keys[key] = value
			end
		else
			-- we don't recognise what this key is supposed to be
			logError("unrecognisedPropertyKey", nil, ftypeof(key))
		end
	end

	for key, value in pairs(specialKeys.self) do
		key:setup(value, applyTo, cleanupTasks)
	end
	for key, value in pairs(specialKeys.descendants) do
		key:setup(value, applyTo, cleanupTasks)
	end

	if props.Parent ~= nil then
		bindProperty(applyTo, "Parent", props.Parent, cleanupTasks)
	end

	for key, value in pairs(specialKeys.ancestor) do
		key:setup(value, applyTo, cleanupTasks)
	end
	for key, value in pairs(specialKeys.observer) do
		key:setup(value, applyTo, cleanupTasks)
	end

	applyTo.Destroying:Connect(function()
		cleanup(cleanupTasks)
	end)
end

return applyProps