function databaseSaveFail(name, id, err)
    return `<failed to store {id} data in {name}> : {err}`
end

function databaseSaveSuccess(name, id)
    return `<successfully saved {id} data in {name}>`
end

function databaseRetrieveFail(name, id, err)
    return `<failed to retrieve {id} data from {name}> : {err} `
end

function databaseRetrieveSuccess(name, id)
    return `<successfully retrieved {id} data from {name}`
end

return {
    databaseSaveSuccess = databaseSaveSuccess,
    databaseSaveFail = databaseSaveFail,

    databaseRetrieveFail = databaseRetrieveFail,
    databaseRetrieveSuccess = databaseRetrieveSuccess,
}