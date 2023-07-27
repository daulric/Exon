local Cleanup = {}
Cleanup.key = "SpecialKey"
Cleanup.kind = "Cleanup"
Cleanup.stage = "observer"

function Cleanup:setup(propValue, instance, tempBin)
    assert(type(propValue) == "table", `{propValue} is not a table; we got a {type(propValue)}`)
    table.insert(tempBin, propValue)
end

return Cleanup