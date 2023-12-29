local Keyboard = {}
Keyboard.__index = Keyboard

local tidy, rednet = require(script.Parent:WaitForChild("tidy")), require(script.Parent:WaitForChild("rednet"))

local UIS = game:GetService("UserInputService")

function Keyboard.new()
    local keyboard = setmetatable({}, Keyboard)
    keyboard.cleany = tidy.init()
    keyboard.keyup = rednet.createSignal()
    keyboard.keydown = rednet.createSignal()
    keyboard.combination = rednet.createSignal()
    keyboard.keybindings = {}

    keyboard.cleany:addMultiple(keyboard.keyup, keyboard.keydown, keyboard.combination)
    keyboard:setup()
    return keyboard

end

function Keyboard:IsKeyDown(key: Enum.KeyCode): boolean
    return UIS:IsKeyDown(key)
end

function Keyboard:AreKeysDown(key1: Enum.KeyCode, key2: Enum.KeyCode)
    return self:IsKeyDown(key1) and self:IsKeyDown(key2)
end

function Keyboard:IsEitherKeyDown(key1: Enum.KeyCode, key2: Enum.KeyCode)
    return self:IsKeyDown(key1) or self:IsKeyDown(key2)
end

function Keyboard:CreateCombination(name : string, ... : Enum.KeyCode)
    local keys = {...}

    assert(self.keybindings[name] == nil, "name already exsists")

    local connection = UIS.InputBegan:Connect(function(input, proccessed)
        local KeyCode = (input.KeyCode == keys[#keys])

        if proccessed then
            return
        end

        if KeyCode then

            for key, _ in pairs(keys) do
                if not self:IsKeyDown(keys[key]) then
                    return
                end

                self.combination:Fire(name)
            end

        end

    end)
    
    self.keybindings[name] = connection


end

function Keyboard:DismantleCombination(name: string)
    if self.keybindings[name] then
        self.keybindings[name]:Disconnect()
        self.keybindings[name] = nil
    end
end

function Keyboard:setup()
    self.cleany:Connect(UIS.InputBegan, function(input, proccessed)
        if proccessed then
            return
        end

        if input.UserInputType == Enum.UserInputType.Keyboard then
            self.keydown:Fire(input.KeyCode)
        end

    end)

    self.cleany:Connect(UIS.InputEnded, function(input, proccessed)
        if proccessed then
            return
        end

        if input.UserInputType == Enum.UserInputType.Keyboard then
            self.keyup:Fire(input.KeyCode)
        end

    end)

end

function Keyboard:Destroy()
    return self.cleany:Clean()
end

return Keyboard