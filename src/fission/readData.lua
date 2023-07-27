return function (id: string, data)
    return setmetatable(data, {
        __index = function(self, key)
            local message = ("%q (%s) is not a valid member of %s"):format(tostring(key), typeof(key), id)
			error(message, 2)
        end,

        __newindex = function(self, key, val)
            local message = ("%q (%s) is not a valid member of %s"):format(tostring(key), typeof(key), id)
            error(message, 2)
        end,

        __tostring = function()
            return id
        end
    })
end