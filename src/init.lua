local lockTable = require(script:WaitForChild("lockTable"))

local devbox = {

    oneframe = require(script:WaitForChild("oneframe")),
    rednet = require(script:WaitForChild("rednet")),
    fission = require(script:WaitForChild("fission")),
    react = require(script:WaitForChild("react")),
    rodb = require(script:WaitForChild("rodb")),

    controllers = require(script:WaitForChild("controllers")),
    util = require(script:WaitForChild("util")),
}

export type devbox = typeof(devbox)

lockTable(devbox, "devbox", {
    indexMessage = "(%s) is not a valid member of devbox!"
})

return devbox