return function (t, func)
    local breakValue

    for index, value in pairs(t) do
        breakValue = func(index, value, func)

        if breakValue == false then
            break
        end

    end

    return breakValue
end