local exon = require(game.ReplicatedStorage.exon)

return function ()
    describe("Exon Database Model", function()
        local database = exon.test.rodbv1
        local profile
        local player
        local profile_storage

        local profile_added

        it("should create a profile", function()
            player = game.Players.PlayerAdded:Wait()
            profile = database.createProfile("Test_Database", player.UserId, {
                Coins= 10,
                Copper = 19,
                Inventory = {},
            })

            expect(profile.data).to.be.a("table")
            expect(profile.template).to.be.a("table")
        end)

        it("should handle events", function()
            expect(function()
                
                profile.saving:Connect(function()
                    print("data is saving")
                end)

                profile.reconciled:Connect(function()
                    print("data got reconciled")
                end)

                profile.closed:Connect(function()
                    print("profile is closing")
                end)

            end).to.be.ok()
        end)

        it("should save the data", function()
            expect(function()
                profile:Save()
            end).to.be.ok()
        end)

        it("should get the data and reconcile", function()

            profile:Get()
            profile:Reconcile()

            for i, v in pairs(profile.template) do
                expect(v).to.equal(profile.data[i])
            end

        end)

        it("should run functions when closing", function()
            expect(function()
                profile:RunFunctionWhenClosing(function()
                    print("database closing")
                end)

                profile:RunFunctionWhenClosing(function()
                    print("Hello There; We are closing")
                end)
            end).to.be.ok()
        end)

        it("should create a profile storage to store profile", function()
            profile_storage = database.createProfileStorage("test_storage")
            expect(profile_storage).to.be.a("table")
        end)

        it("should add the profile to the temporary storage", function()
            profile_added = profile_storage:add(profile)
            expect(profile_added).to.be.a("table")
        end)

        it("should remove profile from the temp storage", function()
            profile_storage:remove(profile_added.Id)
            expect(profile_storage:find(profile_added.Id)).to.equal(nil)
        end)

        it("should close the profile", function()
            expect(profile:CloseProfile()).to.be.ok()
        end)

    end)
end