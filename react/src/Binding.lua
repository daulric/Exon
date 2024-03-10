local rednet = require(script.Parent:WaitForChild("rednet"))
local Symbol = require(script.Parent:WaitForChild("symbol"))
local ElementType = require(script.Parent.markers.ElementType)

local BindingImpl = Symbol.assign("BindingImpl")

local BindingInternalApi = {}

local bindingPrototype = {}

function bindingPrototype:getValue()
	return BindingInternalApi.getValue(self)
end

function bindingPrototype:map(predicate)
	return BindingInternalApi.map(self, predicate)
end

local BindingPublicMeta = {
	__index = bindingPrototype,
	__tostring = function(self)
		return string.format("ReactBinding(%s)", tostring(self:getValue()))
	end,
}

function BindingInternalApi.update(binding, newValue)
	return binding[BindingImpl].update(newValue)
end

function BindingInternalApi.subscribe(binding, callback)
	return binding[BindingImpl].subscribe(callback)
end

function BindingInternalApi.getValue(binding)
	return binding[BindingImpl].getValue()
end

function BindingInternalApi.create(initialValue)
	local impl = {
		value = initialValue,
		changeSignal = rednet.createSignal(),
	}

	function impl.subscribe(callback)
		return impl.changeSignal:Connect(callback)
	end

	function impl.update(newValue)
		impl.value = newValue
		impl.changeSignal:Fire(newValue)
	end

	function impl.getValue()
		return impl.value
	end

	return setmetatable({
		Type = ElementType.Types.Binding,
		[BindingImpl] = impl,
	}, BindingPublicMeta), impl.update
end

function BindingInternalApi.map(upstreamBinding, predicate)

	local impl = {}

	function impl.subscribe(callback)
		return BindingInternalApi.subscribe(upstreamBinding, function(newValue)
			callback(predicate(newValue))
		end)
	end

	function impl.update(_newValue)
		error("Bindings created by Binding:map(fn) cannot be updated directly", 2)
	end

	function impl.getValue()
		return predicate(upstreamBinding:getValue())
	end

	return setmetatable({
		Type = ElementType.Types.Binding,
		[BindingImpl] = impl,
	}, BindingPublicMeta)
end

function BindingInternalApi.join(upstreamBindings)

	local impl = {}

	local function getValue()
		local value = {}

		for key, upstream in pairs(upstreamBindings) do
			value[key] = upstream:getValue()
		end

		return value
	end

	function impl.subscribe(callback)
		local disconnects = {}

		for key, upstream in pairs(upstreamBindings) do
			disconnects[key] = BindingInternalApi.subscribe(upstream, function(_newValue)
				callback(getValue())
			end)
		end

		return function()
			if disconnects == nil then
				return
			end

			for _, connection in pairs(disconnects) do
				connection:Disconnect()
			end

			disconnects = nil :: any
		end
	end

	function impl.update(_newValue)
		error("Bindings created by joinBindings(...) cannot be updated directly", 2)
	end

	function impl.getValue()
		return getValue()
	end

	return setmetatable({
		Type = ElementType.Types.Binding,
		[BindingImpl] = impl,
	}, BindingPublicMeta)
end

return BindingInternalApi