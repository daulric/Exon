local Controllers = {}
--Controllers.__index = Controllers

local Hub = {}
local Tools = script.Parent:WaitForChild("Tools")
local compile = require(Tools:WaitForChild("compile"))

type Controller = {Name: string, [any]: any}

function Controllers.AddController(path: Instance)
    local controllers = {}

    for _, modules in pairs(path:GetDescendants()) do

        if modules:IsA("ModuleScript") then
            local dataIndex = require(modules)

            table.insert(controllers, dataIndex)
            else continue
        end

    end

    return controllers
end

function Controllers.GetController(name: string) : Controller
    local data = Hub[name]

    if data then
        return data
    end

    assert(type(name) == "string", `this is not a string; we got a {type(name)}`)
    assert(Hub[name] ~= nil, `there is no controller with that name`)

end

function Controllers.CreateController(index: Controller)
    assert(type(index) == "table", `this should be a table format: we got a {type(index)}`)
    assert(index.Name ~= nil, "There is no name here!")
    assert(type(index.Name) =="string", `this should be a string: we got a {type(index.Name)}`)
    assert(Hub[index.Name] == nil, `this name already existes! {index.Name}`)

    Hub[index.Name] = index

    return index
end

function Controllers:GetHub()
    local cloned = table.clone(Hub)
    return table.freeze(cloned)
end

return Controllers