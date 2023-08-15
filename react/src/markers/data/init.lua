local data = {}
local markers = script.Parent
local Type = require(markers.Type)
local setTable = require(script.setTable)

data.Change = {}
data.Event = {}
data.Attribute = {}
data.AttributeChange = {}

-- this is for property and attribute change signals

setTable(data.Change, "react.Change", Type.Change, true)
setTable(data.Event, "react.Event", Type.Event, true)
setTable(data.Attribute, "react.Attribute", Type.Attribute)
setTable(data.AttributeChange, "react.Attribute.Change", Type.AttributeChange, true)

return data