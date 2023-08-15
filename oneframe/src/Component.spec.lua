return function ()
	local Component = require(script.Parent:WaitForChild("Component"))

    describe("Component Module", function()

        it("The Component should create a component that runs when published!", function()

            local New = Component:extend("live")

            expect(New).to.be.a("table")
            expect(New).to.ok()

            it("should set state", function()
                New:setState({
                    Money = 10
               }) 
               
               expect(New.state).to.be.a("table")
               expect(New.state.Money).to.be.equal(10)

            end)

            it("should update the state", function()
                New:setState(function(state)
                    state.Money = 80
                    return state
                end)

                expect(New.state.Money).to.never.equal(10)
            end)

            it("should add stuff in the state", function()
                New:setState({
                    Token = 90
                })

                expect(New.state.Money).to.be.ok()
                expect(New.state.Token).to.be.ok()
            end)

            it("should insert individual values", function()
                expect(function()
                    New:setState(10)
                end).to.be.ok()
            end)

            it("self.state should be read only", function()
                expect(function()
                    New.state.Hello = 10
                end).to.be.ok()
            end)

            it("should check to see if state is binded using the extend class", function()
                
                expect(function()
                    Component:setState({
                        idk = true
                    })
                end).to.be.ok()
               
            end)

        end)

        it("return all components", function()
            local Components = Component:GetComponents()
            expect(Components).to.be.a("table")
            expect(Components).to.be.ok()
        end)

        it("return a particular component", function()

            expect(function()
                local liveComponent = Component:GetComponent("live")
                expect(liveComponent).to.be.a("table")
            end).to.be.ok()

            expect(function()
                local testComponent = Component:GetComponent("test")
                expect(testComponent).to.be.a("table")
            end).to.be.ok()

        end)

    end)

end