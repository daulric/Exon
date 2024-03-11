# Exon Controllers

## A module like to for creating modules without the need to require that module

### AddControllers
```lua
controllers.AddControllers(instance: Instance)
```

This catches all modules which contains the controller module and dumps it in a temporary table when requesting the module in the future

### CreateController
```lua
controllers.CreateContoller(t: {Name: string, [any]: any})
```

This creates a controller to be used in other files.

### GetController
```lua
controllers.GetController(name)
```

This gets the controller from the name after `AddControllers` has been called.