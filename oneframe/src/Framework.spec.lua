return function ()
    local Framework = require(script.Parent:WaitForChild("Framework"))

    describe("Framework Component", function()

        it("Components Should Run from folder", function()
            local testFolder = game:GetService("ReplicatedStorage"):WaitForChild("Test")
            local Start = Framework(testFolder, true, "hello", "test")

            Start:andThen(function()
                print("Folder was ran!")
            end):catch(warn)

            expect(Start).to.be.ok()
        end)

        it("should collect and run instances from a table", function()
            local testtable = {
                game:GetService("ReplicatedStorage"):WaitForChild("TestInTable")
            }

            local Start = Framework(testtable, nil, "hello", "test")

            Start:andThen(function()
                print("table was ran!")
            end):catch(warn)

            expect(Start).to.be.ok()
        end)

    end)

end