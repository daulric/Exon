local Ref = require(script.Parent.Parent:WaitForChild("markers").Ref)
local assign = require(script.Parent.Parent:WaitForChild("assign"))

function forwardRef(render)
    return function (props)
        local ref = props[Ref]
        local PropsWithNoRef = assign({}, props)

        return render(PropsWithNoRef, ref)
    end
end

return forwardRef