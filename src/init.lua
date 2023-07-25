local Package = script.Parent

local dabox = {

    oneframe = require(Package:WaitForChild("oneframe")),
    rednet = require(Package:WaitForChild("rednet")),
    fission = require(Package:WaitForChild("fission")),
    retract = require(Package:WaitForChild("retract")),
    rodb = require(Package:WaitForChild("rodb")),

}

function dabox:GetModule(name)
    assert(name ~= "GetModule", `can't return module with this method; {name}`)
    return dabox[name]
end

return dabox