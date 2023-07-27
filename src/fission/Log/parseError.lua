return function (err)
    return {
        key = "Error",
        raw = err,
        message = err:gsub("^.+:%d+:%s*", ""),
        trace = debug.traceback(nil, 2)
    }
end