local Instances = script:WaitForChild("Instances")
local State = script:WaitForChild("State")
local Tools = script:WaitForChild("Tools")

local readData = require(script:WaitForChild("readData"))

local fission = {
    create = require(Instances:WaitForChild("create")),
    update = require(Instances:WaitForChild("update")),

    Children = require(Instances:WaitForChild("Children")),
    Attribute = require(Instances:WaitForChild("Attribute")),
    Cleanup = require(Instances:WaitForChild("Cleanup")),
    Ref = require(Instances:WaitForChild("Ref")),
    Out = require(Instances:WaitForChild("Out")),

    ForPairs = require(State:WaitForChild("ForPairs")),
    ForValues = require(State:WaitForChild("ForValues")),
    ForKeys = require(State:WaitForChild("ForKeys")),

    Value = require(State:WaitForChild("Value")),
    Computed = require(State:WaitForChild("Computed")),
    Observer = require(State:WaitForChild("Observer")),

    OnEvent = require(Instances:WaitForChild("OnEvent")),
    OnChange = require(Instances:WaitForChild("OnChange")),
    OnAttributeChange = require(Instances:WaitForChild("AttributeChange")),
    AttributeOut = require(Instances:WaitForChild("AttibuteOut")),

    cleanup = require(Tools:WaitForChild("cleanup")),
    peek = require(State:WaitForChild("peek"))
}

readData("fission", fission)

return fission