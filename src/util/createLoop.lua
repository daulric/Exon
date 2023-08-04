return function (item, func)
    local breakValue

    while item do
        breakValue = func(item, func)

        if breakValue == false then
            break
        end

    end

    return breakValue
end