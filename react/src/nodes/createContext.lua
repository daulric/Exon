local Component = require(script.Parent.Parent:WaitForChild("Component"))
local createFragment = require(script.Parent:WaitForChild("createFragment"))
local rednet = require(script.Parent.Parent:WaitForChild("rednet"))
local Children = require(script.Parent.Parent:WaitForChild("markers"):WaitForChild("Children"))
local Symbol = require(script.Parent.Parent:WaitForChild("markers"):WaitForChild("Symbol"))

function createIndex(value)
    return {
        value = value,
        onUpdate = rednet.createSignal()
    }
end

function createProducer(context)
    local Producer = Component:extend("Producer Component")

    function Producer:init(props)
        self.contextEntry = createIndex(props.value)
        self:__addContext(context.key, self.contextEntry)
    end

    function Producer:willUpdate(nextProps)
        if nextProps.value ~= self.props.value then
            self.contextEntry.value = nextProps.value
        end
    end

    function Producer:didUpdate(prevProps)
        if prevProps.value ~= self.props.value then
            self.contextEntry.onUpdate:Fire(self.props.value)
        end
    end

    function Producer:render()
        return createFragment(self.props[Children])
    end

   return Producer
end

function createConsumer(context)
    local Consumer = Component:extend("Consumer")

    function Consumer.validateProps(props)
        if type(props.render) ~= "function" then
            return false, "The Consumer Expects a Function"
        else
            return true
        end
    end

    function Consumer:init()
        self.contextEntry = self:__getContext(context.key)
    end

    function Consumer:didUpdate()
        if self.contextEntry ~= nil then
            self.lastValue = self.contextEntry.value
        end
    end

    function Consumer:didMount()
        if self.contextEntry ~= nil then
            self.connection = self.contextEntry.onUpdate:Connect(function(newValue)
                if newValue ~= self.lastValue then
                    self:setState({})
                end
            end)
        end
    end

    function Consumer:willUnmount()
        if self.connection then
            self.connection:Disconnect()
            self.connection = nil
        end
    end

    function Consumer:render()
        local value

        if self.contextEntry ~= nil then
            value = self.contextEntry.value
        else
            value = context.defaultEntry
        end

        return self.props.render(value)
    end

    return Consumer
end

local Context = {}
Context._index = Context

function Context.new(defaultEntry)
    return setmetatable({
        defaultEntry = defaultEntry,
        key = Symbol.assign("Context Key")
    }, Context)
end

function Context.__tostring()
    return "Context Provider"
end

function createContext(entry)
    local context = Context.new(entry)

    return {
        Producer = createProducer(context),
        Consumer = createConsumer(context)
    }
end

return createContext