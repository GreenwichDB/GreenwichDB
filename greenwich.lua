-- Variables
local dss = game:GetService("DataStoreService")
local db = dss:GetDataStore("greenwich")

-- Tables
local greenwich = {}
local dbFunctions = {}
local cache = {}

-- Functions
function greenwich:GetDB(name)
    local new = {}
    new.name = name
    coroutine.resume(coroutine.create(function()
        for k, v in pairs(dbFunctions) do
            local fn = function(...)
                local args = {...}
                return v(unpack(new), unpack(args))
            end
            new[k] = fn
            new[string.lower(k)] = fn
        end
    end))
    return new
end

function dbFunctions:Set(store, key, value)
    store = store.name
    cache[store .. key] = value
    db:SetAsync(store .. key, value)
    return value
end

function dbFunctions:Get(store, key)
    store = store.name
    if not not cache[store .. key] then 
        return cache[store .. key]
    else
        local val = db:GetAsync(store .. key)
        cache[store .. key] = val
        return val
    end
end

function dbFunctions:Delete(store, key)
    store = store.name
    local success, val = pcall(function()
        return db:RemoveAsync(store .. key)
    end)
    cache[store .. key] = nil
    if val and success then
        return true
    else
        return false
    end
end

function dbFunctions:Has(store, key)
    store = store.name
    if not not cache[store .. key] then
        return not not cache[store .. key]
    else
    return not not db:GetAsync(store .. key)
    end
end

-- Returning everything.
return greenwich
