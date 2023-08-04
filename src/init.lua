local devbox = {

    oneframe = require(script:WaitForChild("oneframe")),
    rednet = require(script:WaitForChild("rednet")),
    fission = require(script:WaitForChild("fission")),
    retract = require(script:WaitForChild("retract")),
    rodb = require(script:WaitForChild("rodb")),

    controllers = require(script:WaitForChild("controllers")),
    util = require(script:WaitForChild("util")),
}

export type devbox = typeof(devbox)

return devbox