local lockTable = require(script:WaitForChild("lockTable"))

local react = require(script:WaitForChild("react"))
local createReactHook = require(script:WaitForChild("createReactHook"))(react)

local oneframe = require(script:WaitForChild("oneframe"))

local devbox = {

    oneframe = oneframe,
    react = react,

    -- Packages
    rednet = require(script:WaitForChild("rednet")),
    fission = require(script:WaitForChild("fission")),
    rodb = require(script:WaitForChild("rodb")),

    -- Utils and Stuff
    controllers = require(script:WaitForChild("controllers")),
    util = require(script:WaitForChild("util")),

    -- Hooks For Certain Modules,
    createReactHook = createReactHook,
}

export type devbox = typeof(devbox)

lockTable(devbox, "devbox", {
    indexMessage = "(%s) is not a valid member of devbox!"
})

return devbox