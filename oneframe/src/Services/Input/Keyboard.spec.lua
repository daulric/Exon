return function ()
    local KeyboardModule = require(script.Parent:WaitForChild("Keyboard"))

    local Keyboard = KeyboardModule.new()
    expect(Keyboard).to.be.ok()

    describe("should listen for signals", function()

        it("should listen for combinations", function()
            local connection = Keyboard.combination:Connect(function(name)
                if name == "hello" then
                    print("Hello user")
                end
            end)

            expect(connection).to.be.ok()

        end)

        it("should listen for input started", function()
            local connection = Keyboard.keydown:Connect(function(key)
                if key == Enum.KeyCode.A then
                    print("A was clicked!")
                end
            end)

            expect(connection).to.be.ok()
        end)

        it("should listen for input ended", function()
            
            local connection = Keyboard.keyup:Connect(function(key)
                if key == Enum.KeyCode.A then
                    print("A was released!")
                end
            end)

            expect(connection).to.be.ok()
        end)

    end)

    describe("key down functions and combinations", function()
        it("should check if a key is down", function()
            local isdown = Keyboard:IsKeyDown(Enum.KeyCode.C)
            expect(isdown).to.be.a("boolean")
        end)

        it("should check if 2 keys are down", function()
            local isdown = Keyboard:AreKeysDown(Enum.KeyCode.LeftShift, Enum.KeyCode.C)
            expect(isdown).to.be.a("boolean")
        end)

        it("should check if either keys are down", function()
            local isDown = Keyboard:IsEitherKeyDown(Enum.KeyCode.G, Enum.KeyCode.B)
            expect(isDown).to.be.a("boolean")
        end)

        it("should create combination", function()
            expect(
                Keyboard:CreateCombination("hello", Enum.KeyCode.B, Enum.KeyCode.A)
            ).to.be.equal(nil)
        end)

        it("should dismantle combination", function()
            expect(
                Keyboard:DismantleCombination("hello")
            ).to.be.equal(nil)
        end)

        it("should destroy the keyboard", function()
            expect(Keyboard:Destroy()).to.be.ok()
        end)
    end)

end