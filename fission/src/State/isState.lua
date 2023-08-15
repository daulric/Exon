local function isState(data: any): boolean
    return typeof(data) == "table" and typeof(data._peek) == "function"
end

return isState