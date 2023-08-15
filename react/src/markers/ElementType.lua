local ElementTypeInternal = {}

type ElementKindType = typeof(ElementTypeInternal)

local ElementType: ElementKindType = newproxy(true)

local Symbol = require(script.Parent.Symbol)

local Gateway = require(script.Parent:WaitForChild("Gateway"))

local ElementKindType = {
    Host = Symbol.assign("react.Element.Host"),
    Functional = Symbol.assign("react.Element.Function"),
    StatefulComponent = Symbol.assign("react.Element.StatefulComponent"),
    StatefulComponentInstance = Symbol.assign("react.Component.Instance"),

    --// Other Stuff
    Fragment = Symbol.assign("react.Fragment"),
    Gateway = Symbol.assign("react.Gateway"),
    Element = Symbol.assign("react.Element"),
    VirtualTree = Symbol.assign("react.VirtualTree"),
    Binding = Symbol.assign("Binding")
}

ElementTypeInternal.Types = ElementKindType
ElementTypeInternal.Key = Symbol.assign("Private Key")

local Types = {
    ["string"] = ElementKindType.Host,
    ["function"] = ElementKindType.Functional,
    [Gateway] = ElementKindType.Gateway
}

function noop()
    return nil
end

function ElementTypeInternal.typeof(element)

    if Types[typeof(element)] then
        return Types[typeof(element)]
    end

    if element == Gateway then
        return Types[Gateway]
    end

    if typeof(element) == "table" then
        if element.Type == ElementKindType.StatefulComponent then
            return ElementKindType.StatefulComponent
        end

        if element.Type == ElementKindType.Fragment then
            return ElementKindType.Fragment
        end
    end

end

function ElementTypeInternal.of(element)

    if type(element) ~= "table" then
        return nil
    end

    return element.Type
end

function ElementTypeInternal.iterateElements(index)

    local regType = typeof(index)
    local richType = ElementTypeInternal.of(index)

    if index.Type then

        local called = false

        return function (_, _)
            if called then
                return nil 
            else
                called = true
                return ElementTypeInternal.Key, index
            end
        end

    end

    if index == nil or regType == "boolean" then
        return (noop :: any)
    end

    if regType == "table" then
        return pairs(index)
    end

    error("This is not a valid elements! "..tostring(index))
end

function ElementTypeInternal.getElementByID(elements, key)

    if elements == nil or typeof(elements) == "boolean" then
		return nil
	end

	if elements.Type == ElementTypeInternal.Types.Element then
		if key == ElementTypeInternal.Key then
            print("Got a Table using Private Key!")
			return elements
		end

		return nil
	end

	if typeof(elements) == "table" then
		return elements[key]
	end

	error("Invalid elements")

end

getmetatable(ElementType).__index = ElementTypeInternal

return ElementType