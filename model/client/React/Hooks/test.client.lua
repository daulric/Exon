local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local devbox = require(ReplicatedStorage:WaitForChild("devbox"))

local react = devbox.react
local createReactHook = devbox.createReactHook

local button = createReactHook(function(props, hooks)
    local count, setCount = hooks.useState(0)

    hooks.useEffect(function()
        print("the count is on ", count)
    end)

    return react.createElement("TextButton", {
        Name = "Test React Hook",
        Text = `Count : {count}`,
        TextScaled = true,
        Size = UDim2.fromScale(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),

        [react.Event.MouseButton1Click] = function(element)
            setCount(count + 1)
        end,
    })

end)

local element = react.createElement("ScreenGui", {
    Name = "React Hook Test",
    IgnoreGuiInset = true
}, {
    Hook = react.createElement(button),
})