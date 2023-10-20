# This is just a Quick Guide

## createElement
 
#### Type
```lua
-- This is what it is
createElement(class, props, ...)
```

#### Example
- ##### Component
```lua
local component = Component:extend("My Class")

function component:render()
    return createElement("class-here", {props here}, self.props[Chilren], {
        other children here -- This can take in the internal children and external children at the same time!
    }) 
end

return component
```

- ##### Function
```lua
function test(props)
    return createElement("class-here", { props here }, props[Chilren], {
        other children here -- This can take in the internal children and external children at the same time!
    })
end
```
## createFragment

#### Type

```lua
createFragment({ chilren here })
```

## createRef

#### Type
```lua
createRef()
```

#### Example
```lua
local instance = createRef()

local element = createElement("Part", { 
    [Ref] = instance, -- the part will be linked to the `instance` variable.
})

local part = instance:getValue() -- this will retrun the value which is the part!
```