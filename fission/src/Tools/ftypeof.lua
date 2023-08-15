function ftypeof(data)
    local typeString = type(data)

    if typeString == "table" and type(data.key) == "string" then
        return data.key
    else
        return typeString
    end
end

return ftypeof