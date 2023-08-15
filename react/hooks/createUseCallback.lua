return function (useMemo)
    return function (callback, dependencies)
        return useMemo(function()
            return callback
        end, dependencies)
    end
end