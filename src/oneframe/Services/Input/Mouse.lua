local Mouse = {}
Mouse.__index = Mouse

local Utilities = script.Parent.Parent.Parent:WaitForChild("Utilities")
local Signal = require(Utilities.Signal)
local Cleany = require(Utilities.Cleany)

local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local default_distance = 1000

function Mouse.new()
    local mouse = setmetatable({}, Mouse)
    mouse._cleany = Cleany.create()
    mouse.LeftDown = Signal.new()
    mouse.LeftUp = Signal.new()
    mouse.RightDown = Signal.new()
    mouse.RightUp = Signal.new()
    mouse.Scrolled = Signal.new()

    mouse._cleany:AddMultiple(mouse.LeftDown, mouse.LeftUp, mouse.RightDown, mouse.RightUp, mouse.Scrolled)

    mouse:_setup()

    return mouse

end

function Mouse:_setup()
    self._cleany:Connect(UIS.InputBegan, function(input, proccessed)
        if proccessed then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.LeftDown:Fire()
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            self.RightDown:Fire()
        end
    end)

    self._cleany:Connect(UIS.InputEnded, function(input, proccessed)
        if proccessed then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.LeftUp:Fire()
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            self.RightUp:Fire()
        end

    end)

    self._cleany:Connect(UIS.InputChanged, function(input, processed)
		if processed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseWheel then
			self.Scrolled:Fire(input.Position.Z)
		end
	end)

end

function Mouse:IsLeftDown()
    return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
end

function Mouse:IsRightDown()
    return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
end

function Mouse:GetDelta()
    return UIS:GetMouseDelta()
end

function Mouse:GetRay(override: Vector2?)
    local mousePos = override or UIS:GetMouseLocation()
	local viewportRay = workspace.CurrentCamera:ViewportPointToRay(mousePos.X, mousePos.Y)
	return viewportRay
end

function Mouse:Raycast(RaycastParams: RaycastParams, distance: number?, override: Vector2?)

    local viewport = self:GetRay(override)
    local raycast = workspace:Raycast(
        viewport.Origin,
        viewport.Direction * (distance or default_distance),
        RaycastParams
    )

    return raycast
end

function Mouse:Project(distance: number?, override:Vector2?)
    local viewport = self:GetRay(override)
    return viewport.Origin + (viewport.Direction.Unit * (distance or default_distance))
end

function Mouse:Lock()
    UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
end

function Mouse:LockCenter()
    UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
end

function Mouse:Unlock()
    UIS.MouseBehavior = Enum.MouseBehavior.Default
end

function Mouse:Destroy()
    return self._cleany:Clean()
end

return Mouse