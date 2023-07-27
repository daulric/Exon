return function ()
    local Cleany = require(script.Parent:WaitForChild("Cleany"))
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")

    describe("it should clean modules", function()
        local Cleanup  = Cleany.create()
        local Object = Instance.new("Part")

        expect(Cleanup).to.be.ok()

        it("should add connections to the clean up table", function()
            local Connection = Cleanup:Connect(Players.ChildAdded, function(child)
                print("child added:", child)
            end)

            local Connection2 = Cleanup:Connect(Players.ChildRemoved, function(child)
                print("child removed:", child)
            end)

            expect(Connection).to.be.ok()
            expect(Connection2).to.be.ok()

        end)

        it("should run corotines", function()
            local coro = Cleanup:Add(coroutine.create(function()
                print("hello corotine working")
            end))

            coroutine.resume(coro)
            expect(coro).to.be.ok()
        end)

        it("should add objects", function()
            local added = Cleanup:Add(Object)
            print("Part Join Workspace", added)
            added.Parent = workspace
            expect(added).to.be.ok()
        end)

        it("should add multiple objects", function()
            local added = Cleanup:AddMultiple(Instance.new("RemoteEvent"), Instance.new("Part"))
            print("items:", added)
            expect(added).to.be.a("table")
        end)

        it("should remove objects", function()
            expect(Cleanup:Remove(Object)).to.never.be.ok()
        end)

        it("should clean itself", function()
            expect(Cleanup:Clean()).to.be.ok()
        end)

    end)

end