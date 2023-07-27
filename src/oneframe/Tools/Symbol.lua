local Symbol = {}


function  Symbol.assign(name)
    local new = newproxy(true)

    getmetatable(new).__index = function()
        return ("oneframe.assign(%s)"):format(name)
    end

    return new
end

return Symbol