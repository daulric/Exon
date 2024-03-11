# Exon Database (DB)

### This is a database manager that manages data for you game

## **API**

### LoadProfile
```lua
db.LoadProfile(database: string | number, Id: string | number, template: {[any]: any}?)
```

This loads the profile for the player or object

### data
```lua
profile.data : {[any]: any}
```

This is where the user can get, edit and store the data when the profile is loaded

### Reconcile
```lua
db:Reconcile()
```

This compares data in the template to your database and fills the missing pieces / keys.

### Save
```lua
db:Save()
```
This saves the data in the database

### AutoSave
```lua
db:AutoSave()
```
This autosaves data in the database

### Close
```lua
db:Close()
```

This save and closes the profile of the player or object.

### ListenForClosure
```lua
db:ListenForClosure(callback: () -> ())
```

This listen for when the database is closing

