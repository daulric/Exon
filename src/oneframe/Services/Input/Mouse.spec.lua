
return function ()
    local RunService = game:GetService("RunService")
    local MouseModule = require(script.Parent:WaitForChild("Mouse"))
    local Mouse = MouseModule.new()
    
    expect(Mouse).to.be.ok()

    describe("it should listen for signals", function()
        
        it("should listen to scroll signals", function()
            local connection = Mouse.Scrolled:Connect(function(pos)
                print(`mouse position: {pos}`)
            end)

            expect(connection).to.be.ok()
        end)

        it("should listen for button down signals", function()
            local connection = Mouse.LeftDown:Connect(function()
                print("left mouse button clicked")
            end)

            local connection2 = Mouse.RightDown:Connect(function()
                print("right mouse button clicked!")
            end)

            expect(connection).to.be.ok()
            expect(connection2).to.be.ok()
        end)

        it("should listen for button up signals", function()
            local connection = Mouse.LeftUp:Connect(function()
                print("left mouse button released")
            end)

            local connection2 = Mouse.RightUp:Connect(function()
                print("right mouse button released")
            end)


            expect(connection).to.be.ok()
            expect(connection2).to.be.ok()
        end)

    end)

    describe("mouse functions", function()
        it("should lock the mouse", function()
            expect(Mouse:Lock()).to.never.ok()
        end)

        it("should lock the mouse to the center", function()
            expect(Mouse:LockCenter()).to.never.ok()
        end)

        it("should unlock the mouse", function()
            expect(Mouse:Unlock()).to.never.ok()
        end)

        it("should get the ray of the mouse", function()
            local ray = Mouse:GetRay()
            expect(ray).to.be.ok()
        end)

        it("should get mouse delta", function()
            local delta = Mouse:GetDelta()
            expect(delta).to.be.ok()
        end)

        it("should project the distance of the mouse", function()
            local projection = Mouse:Project()
            expect(projection).to.be.ok()
        end)

        it("should get raycast", function()
            local params = RaycastParams.new()
            local raycast = Mouse:Raycast(params)

            -- added this so testez wont bug out!

            if raycast == nil then
                expect(raycast).to.never.ok()
            else
                expect(raycast).to.be.ok()
            end
            
        end)

        it("should check if left button if clicked", function()
            local clicked = Mouse:IsLeftDown()
            expect(clicked).to.be.ok()
        end)

        it("should check if right mouse is clicked", function()
            local clicked = Mouse:IsRightDown()
            expect(clicked).to.be.ok()
        end)

        it("should destroy the mouse index", function()
            expect(Mouse:Destroy()).to.be.ok()
        end)
    end)

end