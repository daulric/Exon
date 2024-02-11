local DB = {}
DB.__index = DB

-- Getting Services
local DataBaseService = game:GetService("DataStoreService")
local rednet = require(script:WaitForChild("rednet"))
local tidy = require(script:WaitForChild("tidy"))

type ProfileId = string | number
type Database = string | number;
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

function DB.LoadProfile(database: Database, Id: ProfileId, template: Table?)
    local cleanUp = tidy.init()
    template = template or {}

    local profile = {
        _cleanup = cleanUp,
        data = {},
        Settings = {
            EnableAutoSaveEvent = true,
            AutoSaveTime = 10,
        },

        Id = Id,
        template = template,
        Name = database,
        database = DataBaseService:GetDataStore(database),
        isSaving = false,
        isClosing = false,
        isReconciling = false,
        isAutoSavingCancel = false,
        saving = cleanUp:add(rednet.createSignal()),
        reconciled = cleanUp:add(rednet.createSignal()),
    }

    local self = setmetatable(profile, DB)
    self:__get()

    return self
end

function DB:ListenForClosure(callback)
    if type(callback) == "function" then
        self._cleanup:add(callback)
    end
end

function DB:Save(fireSaveEvent: boolean?)

    if fireSaveEvent == nil then
        fireSaveEvent = true
    end

    if self.isSaving == true then
        warn(`[Exon DB]: {self.Id} Profile in {self.Name} Currently Saving Data!`)
        return
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
            if fireSaveEvent == false then
                return
            end

            self.saving:Fire(self.Id)
        end
    else
        warn(err)
    end

    task.wait()
    self.isSaving = false
end

function DB:AutoSave()
    -- // AutoSaving Data every 30 seconds
    task.spawn(function()
        while task.wait(self.Settings.AutoSaveTime) do
            if self.isAutoSavingCancel == true then
                break
            end

            self:Save(self.Settings.EnableAutoSaveEvent) -- Fire the events in autosaving
            task.wait()
        end
    end)
end

function DB:__get()

    local function getdata(olddata)
        if olddata == nil then
            olddata = {}
        end

        --// Session Locking
        if olddata.sessionId == nil then
            olddata.sessionId = game.JobId
        elseif olddata.sessionId ~= game.JobId then
            warn(`[Exon DB]: {self.Id} profile in {self.Name} is currently opened in another server;`)
            return olddata
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
        warn(err)
    end

    -- This returns a cloned frozen version of the data
    return table.freeze(table.clone(self.data))
end

-- // This fills in the missing part of the data from the template
function DB:Reconcile()

    if self.isReconciling == true then
        warn(`[Exon DB]: {self.Id} Profile in {self.Name} is Reconciling Data!`)
        return
    end

    self.isReconciling = true

    -- This compares the template to the actual data and fills in the missing spaces
    reconcileTable(self.template, self.data)
    self.reconciled:Fire(self.Id)
    task.wait()
    self.isReconciling = false
end

-- // This saves and closes the profile!
function DB:Close()

    if self.isClosing == true then
        warn(`[Exon DB]: {self.Id} Profile in {self.Name} Has Closed or Already Closing!`)
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
                warn("[Exon DB]: The `self.data` either not a table or it doesn't exsist!")
                return
            end

            return oldData
        end)
    end)

    if not success then
        warn(err)
    end

    self.isAutoSavingCancel = true
    self.template = nil
    self.data = nil
    task.wait()
    self._cleanup:Clean()  -- Executes functions and clean objects and events.
    self = {}
end

return DB