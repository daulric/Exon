local lockTable = require(script:WaitForChild("lockTable"))

local react = require(script:WaitForChild("react"))
local oneframe = require(script:WaitForChild("oneframe"))
local import = require(script:WaitForChild("import"))
local util = require(script:WaitForChild("util"))

local addons = script:WaitForChild("addons")
local api = script:WaitForChild("api")

local createReactHook = require(addons:WaitForChild("createReactHook"))(react)

local exon = {

    oneframe = oneframe,
    react = react,
    hook = createReactHook,

    -- Packages
    rednet = require(script:WaitForChild("rednet")),
    db = require(script:WaitForChild("db")),

    -- Utils and Stuff
    controllers = require(script:WaitForChild("controllers")),
    util = util,

    -- Addons,
    addons = {
        tidy = require(addons:WaitForChild("tidy")),
        input = require(addons:WaitForChild("input")),
    },

    api = {
        auth = require(api:WaitForChild("auth")),
    },

    -- Import Stuff
    import = import,
}

lockTable(exon, "exon", {
    indexMessage = "(%s) is not a valid member of exon!"
})

return exon