local RoDB = {}
RoDB.__index = RoDB

-- Getting Services
local DataBaseService = game:GetService("DataStoreService")
local rednet = require(script:WaitForChild("rednet"))
local tidy = require(script:WaitForChild("tidy"))

type Profile = string | number
type Database = string | number;

function createSymbol(name)
    local _blank_data = newproxy(true)

    getmetatable(_blank_data).__tostring = function()
        return ("Key(%s)"):format(name)
    end

    return _blank_data;
end

type Table = {[any]: any}

function reconcileTable(template: Table, data: Table, ignoreCloneToData: boolean?)
    for i, v in pairs(template) do
        if data[i] == nil then
            data[i] = v
        end
    end
end

function RoDB.createProfile(Name: Database, Id: Profile, template: Table)
    local profile = {
        _cleanup = tidy.init(),
        data = {},
        Id = Id,
        template =  {},
        database = DataBaseService:GetDataStore(Name),
        isOpened = true,
        closed = rednet.createSignal(),
        saving = rednet.createSignal(),
        reconciled = rednet.createSignal(),
    }

    local self = setmetatable(profile, RoDB)
    self:__createTemplate(template)

    -- This adds the template to the template table within the profile
    return self
end

function RoDB:__createTemplate(template)

    if type(template) ~= "table" then
        warn(`must use a table; {debug.traceback()}`)
    end

    self.template = template
end

function RoDB:RunFunctionWhenClosing(func)
    if type(func) == "function" then
        self._cleanup:add(func)
    end
end

function RoDB:Save()

    local function saveData(oldData)
        if oldData == nil then
            oldData = {}
        end
    
        for i, v in pairs(self.data) do
            oldData[i] = v
        end
    
        return oldData
    end

    local success, err = pcall(self.database.UpdateAsync, self.database, self.Id, saveData)

    if success then
        self.saving:Fire(self.Id)
    else
        warn(err)
    end

end

function RoDB:Get()
    local success, data = pcall(function()
        return self.database:GetAsync(self.Id)
    end)

    if success then
        for i, v in pairs(data) do
            self.data[i] = v
        end
    end

    -- This returns a cloned frozen version of the data
    return table.freeze(table.clone(self.data))
end

function RoDB:Reconcile()
    -- This compares the template to the actual data and fills in the missing spaces
    reconcileTable(self.template, self.data)
    self.reconciled:Fire(self.data)
end

function RoDB:CloseProfile()
    if self.isOpened ~= true then
        return
    end

    self.data = nil
    self.template = nil
    self._cleanup:Clean()  -- Executes functions and clean objects.
    self.closing:Fire(self.Id)
end

function RoDB.createProfileStorage(name: string)
    -- This is for managing storage is the case that you are dealing with a player or a team while in a game.
    local tag = createSymbol(name)
    local storage = {
        [tag] = {}
    }

    function storage:add(profile)

        if not profile.Id then
            warn(`Not a Valid Database; {debug.traceback()}`)
        end

        if profile.isOpened ~= true then
            warn(`The Database is currently closed; {debug.traceback()}`)
        end

        if storage[tag][name][profile.Id] == nil then
            storage[tag][name][profile.Id] = profile
        else
            warn(`Storage Already Exsist with current ID: {profile.Id} in {name}`)
        end

    end

    function storage:remove(profileId: string)
        local currentStorage = storage[tag][name][profileId]

        if currentStorage ~= nil then
            storage[tag][name][profileId] = nil
        end
    end

    return storage
end

return RoDB