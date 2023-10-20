local markers = script.Parent.Parent:WaitForChild("markers")

local ElementType = require(markers.ElementType)
local Children = require(markers.Children)

function extractData(ProccessChildren, children)


    if type(ProccessChildren) ~= "table" then return end

    for i, child in pairs(ProccessChildren) do
        if type(child) == "table" then
            if child.Type ~= nil then
                children[i] = child
            else
                extractData(child, children)
            end
        end
    end

end

function createElement(class, props, ...: any)

    local processChildren = {...}
    local children = {}

    props = props or {}

    if processChildren ~= nil then

        extractData(processChildren, children)

        if props[Children] ~= nil then
            warn("there is already children in the props")
            return
        end

        props[Children] = children
    end

    local index = {
        Type = ElementType.typeof(class),
        class = class,
        props = props,
        children = children
    }

    return index
end

return createElement