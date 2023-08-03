local Controllers = {}
local symbol = require(script:WaitForChild("symbol"))

local Hub = {}

function Controllers.AddController(instance: Instance)
    local controllers = {}

    for _, module in pairs(instance:GetChildren()) do
        if module:IsA("ModuleScript") then
            local data = require(module)

            if data.symbol then
                table.insert(controllers, data)
            end

        end
    end

    return controllers
end

function Controllers.CreateController(t)
    assert(type(t) == "table", `{t} is not a table; we got a {type(t)}}`)
    assert(type(t.Name) == "string", `There is no name; {t}`)
    assert(Hub[t.Name] == nil, `{t.Name} already exsists`)

    t.symbol = symbol.assign("Controller - "..t.Name)
    Hub[t.Name] = t

    return t
end

function Controllers.GetController(name)
    assert(name ~= nil and type(name) == "string", `There is no name; we got {name}`)
    assert(Hub[name] ~= nil, `There is no {name} controller created!`)

    return Hub[name]
end

return Controllers