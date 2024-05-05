local Auth = {}
Auth.__index = Auth

local rednet = require(script:WaitForChild("rednet"))
local promise = require(script:WaitForChild("promise"))

type Users = {
    user: {
        username: string,
        password: any,
    }
}

function SuccessAuth(self, callback)
    return promise.new(function(resolve, reject)
        self._successAuthEvent:Connect(function(user, password)

            if type(callback) ~= "function" then
                callback = function()
                    reject("Please add a callback function!")
                end
            end

            if self._users[user] == nil then
                return reject(`User does not exist`)
            end

            if self._users[user].username ~= user then
                return reject(`Username {user} does not exist`)
            end

            if self._users[user].password ~= password then
                return reject(`Incorrect password: {password}`)
            end

            local data = {callback()}
            resolve(unpack(data))
            return unpack(data)
        end)
    end)
end

function Auth.new(Users: Users?)
    Users = Users or {}

    local self = {
        _users = Users,

        _successAuthEvent = rednet.createBindableSignal(),
        successAuth = SuccessAuth,
    }

    setmetatable(self, Auth)
    return self
end

type createUser = {username: string, password: any}

function Auth:createNewUsers(array: { createUser })
    for _, user in pairs(array) do
        self._users[user.username] = user
    end
end

function Auth:Login(username, password) : typeof(promise.new())
    return self._successAuthEvent:Fire(username, password)
end

return Auth