--Variables
local dss = game:GetService("DataStoreService")
local db = dss:GetDataStore("greenwich")

-- Tables
local greenwich = {}
local dbFunctions = {}

--Functions
function greenwich:GetDB(name)
    local new = {}
    new.key = name
    coroutine.resume(coroutine.create(function()
        for k, v in ipairs(dbFunctions) do
            new[k] = function(...)
                local args = { ... }
                v(new.key, unpack(args))
            end

        end
    end))
    return new
end

function dbFunctions:Set(save_key, key, value)
    return value
end

--Returning everything.
return greenwich
