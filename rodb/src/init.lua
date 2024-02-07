local RoDB = {}
RoDB.__index = RoDB

-- Getting Services
local DataBaseService = game:GetService("DataStoreService")
local rednet = require(script:WaitForChild("rednet"))
local tidy = require(script:WaitForChild("tidy"))

type ProfileId = string | number
type Database = string | number;
type Profile = typeof(RoDB.createProfile())
type Table = {[any]: any}

function reconcileTable(template: Table, data: Table)
    for i, v in pairs(template) do
        if data[i] == nil then
            data[i] = v
        elseif type(data[i]) == "table" and type(v) == "table" then
            data[i] = reconcileTable(v, data[i])
        end
    end

    return data
end

function RoDB.LoadProfile(database: Database, Id: ProfileId, template: Table)
    local cleanUp = tidy.init()
    template = template or {}

    local profile = {
        _cleanup = cleanUp,
        data = {},
        Id = Id,
        template = template,
        database = DataBaseService:GetDataStore(database),
        isSaving = false,
        isClosing = false,
        saving = cleanUp:add(rednet.createSignal()),
        reconciled = cleanUp:add(rednet.createSignal()),
    }

    local self = setmetatable(profile, RoDB)
    self:__get()

    return self
end

function RoDB:ListenForClosure(callback)
    if type(callback) == "function" then
        self._cleanup:add(callback)
    end
end

function RoDB:Save()

    if self.isSaving == true then
        error("[Exon RoDB]: Currently Saving Data!")
    end

    self.isSaving = true

    local function saveData(oldData)
        if oldData == nil then
            oldData = {}
        end

        if self.data ~= nil then
            for i, v in pairs(self.data) do
                oldData[i] = v
            end
        end

        return oldData
    end

    local success, err = pcall(self.database.UpdateAsync, self.database, self.Id, saveData)

    if success then
        if self.saving ~= nil or self.isClosing == true then
            self.saving:Fire(self.Id)
        end
    else
        warn(err)
    end

    task.wait()
    self.isSaving = false
end

function RoDB:__get()

    local function getdata(olddata)
        if olddata == nil then
            olddata = {}
        end

        --// Session Locking
        if olddata.sessionId == nil then
            olddata.sessionId = game.JobId
        elseif olddata.sessionId ~= game.JobId then
            error(`{self.Id} profile is currently opened in another server;`)
        end

        for i, v in pairs(olddata) do
            if i ~= "sessionId" then
                self.data[i] = v
            end
        end

        return olddata
    end

    local success, err = pcall(self.database.UpdateAsync, self.database, self.Id, getdata)

    if not success then
        error(err)
    end

    -- This returns a cloned frozen version of the data
    return table.freeze(table.clone(self.data))
end

-- // This fills in the missing part of the data from the template
function RoDB:Reconcile()
    -- This compares the template to the actual data and fills in the missing spaces
    reconcileTable(self.template, self.data)
    self.reconciled:Fire(self.Id)
end

-- // This saves and closes the profile!
function RoDB:Close()

    if self.isClosing == true then
        warn("[Exon RoDB]: Profile is Closed or Already Closing!")
        return
    end

    self.isClosing = true

    local success, err = pcall(function()
        self.database:UpdateAsync(self.Id, function(oldData)
            if oldData.sessionId == game.JobId then
                oldData.sessionId = nil
            end

            if self.data ~= nil and type(self.data) == "table" then
                for i, v in pairs(self.data) do
                    oldData[i] = v
                end
            else
                error("[Exon RoDB]: The self.data either not a table or it doesn't exsist!")
            end

            return oldData
        end)
    end)

    if not success then
        warn(err)
    end

    self.template = nil
    self.data = nil
    task.wait()
    self._cleanup:Clean()  -- Executes functions and clean objects and events.
    self = {}
end

return RoDB