-- Variables
local dss = game:GetService("DataStoreService")
local db = dss:GetDataStore("greenwich")

-- Tables
local greenwich = {}
local dbFunctions = {}

-- Functions
function greenwich:GetDB(name)
    local new = {}
    new.name = name
    coroutine.resume(coroutine.create(function()
        for k, v in pairs(dbFunctions) do
            new[k] = function(...)
                local args = {...}
                return v(unpack(new), unpack(args))
            end
        end
    end))
    return new
end

function dbFunctions:Set(store, key, value)
    store = store.name
    db:SetAsync(store .. key, value)
    return value
end

function dbFunctions:Get(store, key)
    store = store.name
    return db:GetAsync(store .. key)
end

function dbFunctions:Delete(store, key)
    store = store.name
    db:RemoveAsync(store .. key)
    return
end

-- Returning everything.
return greenwich
