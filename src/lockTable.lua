return function (data, id, messages)
    id = id or tostring(data)

    messages.indexMessage = messages.indexMessage or "%q (%s) is not a valid member of %s"

    return setmetatable(data, {
        __tostring = id,

        __index = function(_self, key)
            local message = messages.indexMessage:format(tostring(key), typeof(key), id)

            error(message, 2)
        end,

        __newindex = function(_self, key, _value)
            local message = messages.indexMessage:format(tostring(key), typeof(key), id)

            error(message, 2)
        end,
    })
end