return function (t1:number, t2: number, increment: number, func)
    local breakValue

    for index = t1, t2, increment do
        breakValue = func(index, func)

        if breakValue == false then
            return
        end

    end

    return breakValue
end