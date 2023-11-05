local exon = require(game.ReplicatedStorage:WaitForChild("exon"))

local Util = exon.util

local Items = {
    Bye = "Hello",
    Jeff = "Bazooka",
    Deep = {
        Get = "Not Search",
        Make = "New",
        Deep2 = {
            Get2 = "Search"
        }
    }
}

-- iterating items in a table
task.spawn(function()
    Util.iterate(Items, function(index, value, func)

        if value == "Search" then
            print("found search in the Table", "ID: "..index)
            return false
        elseif type(value) == "table" then
            print("iterating", value)
            return Util.iterate(value, func)
        end
    end)
end)

-- creating a loop
task.spawn(function()
    -- this does a check to see if the table is actually a table
    Util.createLoop(type(Items) == "table", function()
        print("Item is a Table")
        return false
    end)

    -- since the type check for Items is a table,
    -- and we say its not a table
    -- the code will not run!
    Util.createLoop(type(Items) ~= "table", function()
        print("Not Working")
    end)
end)

-- Counted Down From 60
task.spawn(function()

    Util.createCounter(60, 0, -1, function(i)
        print(i)

        if i == 30 then
            print("stopped counting down")
            return false
        end

        task.wait(1)
    end)
end)

-- Counted Up To 60
task.spawn(function()

    Util.createCounter(0, 60, 1, function(i)
        print(i)

        if i == 30 then
            print("stopped counting up!")
            return false
        end

        task.wait(1)

    end)
end)