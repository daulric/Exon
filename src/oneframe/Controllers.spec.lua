return function ()
    local Controllers = require(script.Parent:WaitForChild("Controllers"))

    describe("Controllers Component", function()
        it("should add controllers from the path", function()
            local added = Controllers.AddController(game.ReplicatedStorage.Controllers)
            expect(added).to.be.ok()
        end)

        it("should get a controller", function()
            local controller = Controllers.GetController("test")

            local connection = controller.event:Connect(function(...)
                print(...)
            end)

            task.wait(3)
            controller.event:Fire("Hello", "Test", "Function")

            expect(connection).to.be.ok()
            expect(controller:Get()).to.be.ok()
            expect(controller).to.be.a("table")
        end)
    end)
end