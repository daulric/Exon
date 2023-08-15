local RoDB = {}
RoDB.__index = RoDB

local unknownIndex = 0

local Symbol = require(script:WaitForChild("Symbol"))

local DataBaseService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local RoDBRegistry

if RunService:IsServer() then
    RoDBRegistry = DataBaseService:GetDataStore("RoDB Database Registry")
end

-- Different Services
local ProfileModule = require(script:WaitForChild("Profile"))
local GeneralDBModule = require(script:WaitForChild("GeneralDB"))

local RootDB = require(script:WaitForChild("RootDB"))

RoDB.__tostring = function()
    return "RoDB"
end

type Template = {[any]: any}
function RoDB.create(name: string?, scope: Player | any?, template: Template?)
    local Database = {}

    template = template or {}
    Database.template = template

    if name == nil then
        unknownIndex += 1
        name = "unknownIndex_"..unknownIndex
    end

    if scope then

        if typeof(scope) == "Instance" and scope:IsA("Player") then
            Database.isProfile = Symbol.assign("Profile")
            Database.player = scope
        else
            Database.isGeneral = Symbol.assign("General")
            Database.id = scope
        end

    end

    Database.db = DataBaseService:GetDataStore(name)
    Database.name = name
    Database.data = {}
    Database.isSaving = false
    Database.isRetrieving = false

    for i, v in pairs(template) do
        Database.data[i] = v
    end

    RoDBRegistry:UpdateAsync("Registry", function(oldData)
        if oldData == nil then
            oldData = {}
        end

        if not table.find(oldData, name) then
            print("Inserting a NEw Database", name)
            table.insert(oldData, name)
        end

        return oldData
    end)

    return setmetatable(Database, RoDB)
end

function RoDB:Save()

    if self.isSaving == true then
        return
    end

    self.isSaving = true

    if self.isProfile then
        ProfileModule:SaveData(self, RootDB)
    end

    if self.isGeneral then
       GeneralDBModule:SaveData(self, RootDB)
    end

    task.wait(1)
    self.isSaving = false

end

function RoDB:Retrieve()
    if self.isRetrieving == true then
        return
    end

    self.isRetrieving = true

    if self.isProfile then
        ProfileModule:GetData(self, RootDB)
    end

    if self.isGeneral then
        GeneralDBModule:GetData(self, RootDB)
    end

    task.wait(1)
    self.isRetrieving = false

end

function RoDB:GetRegistry()
    local Data = {}

    RoDBRegistry:UpdateAsync("Registry", function(oldData)
        if oldData == nil then
            oldData = {}
        end

        for i, v in pairs(oldData) do
            Data[i] = v
        end

        return oldData
    end)

    return table.freeze(Data)

end

if RunService:IsServer() then
    return RoDB
elseif RunService:IsClient() then
    return {}
end