local Symbol = require(script.Parent:WaitForChild("Symbol"))

return {
    -- // Event, Property, and Attribute Signals for Events
    Event = Symbol.assign("react.Event"),
    Change = Symbol.assign("react.Change"),
    Attribute = Symbol.assign("react.Attribute"),
    AttributeChange = Symbol.assign("react.Attribute.Change"),
}