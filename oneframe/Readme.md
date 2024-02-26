# __OneFrame__

A Module for Handling Multiple Modules Under a Single Server or a Client

# OnStart
```lua
OneFrame:OnStart(Folder or Table, ...any)
```

This executes all modules within a folder or has been listed in a table.

# __Component__


## __Two Types of Component__

### _Module Component_

`OneFrame.Component`
-- This is the component class that contains all the stuff for the various component.

```lua
OneFrame.Component.create(name: String)
```
This creates a component to be executed when `:OnStart` has been called from the Server or Client

### _Functional Component_
This is where you create a module that returns a function

```lua
return function(start, closing)
    start(function(...)
        print(...)
    end)

    closing(function()
        print("game is closing!")
    end)
end
```

#### __Note:__ If you use this method to execute your code, this is way faster that using the module component.

When I mean way faster, i mean that the code executes before they mention the Success message!
