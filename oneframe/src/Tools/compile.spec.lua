return function ()
    local compile = require(script.Parent:WaitForChild("compile"))

    describe("Should Compile the Table", function()

        it("should compile the table", function()
            local test = compile({
                Cash = 100,
                Token = 10
            })

            expect(test).to.be.ok()
        end)

        it("should not get any nonexsisting key", function()
            local test = compile({
                hello = 1,
                hi = 9,
            })

            expect(function()
                return test.bye
            end).to.throw()
        end)

        it("should not add any nonexsisting key", function()
            local test = compile({
                money = 90,
                cash = 10,
            })
            expect(function()
                test.token = 10
            end).to.throw()
        end)

    end)

end