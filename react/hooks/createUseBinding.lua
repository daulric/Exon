return function (react, useValue)
    return function (defaultVal)
        return unpack(useValue( { react.createBinding(defaultVal) } ).value)
    end
end