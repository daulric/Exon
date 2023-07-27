
local dabox = {

    oneframe = require(script:WaitForChild("oneframe")),
    rednet = require(script:WaitForChild("rednet")),
    fission = require(script:WaitForChild("fission")),
    retract = require(script:WaitForChild("retract")),
    rodb = require(script:WaitForChild("rodb")),

}

function dabox:GetModule(name)
    assert(name ~= "GetModule", `can't return module with this method; {name}`)
    return dabox[name]
end

return dabox