-- \\ Utils // --
local nodes = script:WaitForChild("nodes")
local markers = script:WaitForChild("markers")

local data = require(markers:WaitForChild("data"))

local createElement = require(nodes:WaitForChild("createElement"))
local createFragment = require(nodes:WaitForChild("createFragment"))
local createContext = require(nodes:WaitForChild("createContext"))
local ComponentAspect = require(script:WaitForChild("Component"))
local createRef = require(nodes:WaitForChild("createRef"))
local forwardRef = require(nodes:WaitForChild("forwardRef"))

local Binding = require(script:WaitForChild("Binding"))

-- Reconciler v2
local renderer = require(script:WaitForChild("Renderer"))
local Reconciler = require(script:WaitForChild("Reconciler"))(renderer)

-- \\ compile // --
local freeze = require(script:WaitForChild("freeze"))

local react = {
    mount = Reconciler.mountVirtualTree,
    unmount = Reconciler.unmountVirtualTree,
    update = Reconciler.updateVirtualTree,

    createElement = createElement,
    createFragment = createFragment,
    createContext = createContext,
    createRef = createRef,
    createBinding = Binding.create,
    forwardRef = forwardRef,

    --// Event, Property, and Attribute Signals
    Change = data.Change,
    Event = data.Event,
    AttributeChange = data.AttributeChange,

    --// Attributes and Children
    Attribute = data.Attribute,
    Children = require(markers.Children),
    Gateway = require(markers.Gateway),
    Ref = require(markers.Ref),

    Component = ComponentAspect,
}

freeze(react, "react")
return react