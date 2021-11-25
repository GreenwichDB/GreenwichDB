-- Variables
local dss = game:GetService("DataStoreService")
local db = dss:GetDataStore("Greenwich")

-- Tables
local greenwich = {}
local dbFunctions = {}
local cache = {}
local queue = {}

-- Helper function

function addToQueue(fn)
    queue[os.time()] = fn
end

-- Functions
function greenwich:GetDB(name)
    local new = {}
    new.name = name
    coroutine.resume(
        coroutine.create(
            function()
                for k, v in pairs(dbFunctions) do
                    local fn = function(...)
                        local args = {...}
                        return v(unpack(new), unpack(args))
                    end
                    new[k] = fn
                    new[string.lower(k)] = fn
                end
            end
        )
    )
    return new
end

function dbFunctions:Set(store, key, value, shouldSave)
    store = store.name
    cache[store .. key] = value
    if shouldSave == nil or shouldSave == true then
        addToQueue(
            function()
                db:SetAsync(store .. key, value)
            end
        )
    end
    return value
end

function dbFunctions:Get(store, key)
    store = store.name
    if not (not cache[store .. key]) then
        return cache[store .. key]
    else
        local val = db:GetAsync(store .. key)
        cache[store .. key] = val
        return val
    end
end

function dbFunctions:Delete(store, key)
    store = store.name
    addToQueue(
        function()
            db:RemoveAsync(store .. key)
        end
    )
    cache[store .. key] = nil
    return true
end

function dbFunctions:Has(store, key)
    store = store.name
    if not (not cache[store .. key]) then
        return not (not cache[store .. key])
    else
        return not (not db:GetAsync(store .. key))
    end
end

function dbFunctions:Save(store, key)
    store = store.name
    if cache[store .. key] == nil then
        return false
    else
        addToQueue(
            function()
                db:SetAsync(store .. key, cache[store .. key])
            end
        )
        return true
    end
end

function dbFunctions:Fetch(store, key)
    store = store.name
    addToQueue(function()
        local value = db:GetAsync(store .. key)
        cache[store .. key] = value
    end)
    return true
end

function greenwich:EndQueue()
    for k, v in pairs(queue) do
        local s, e =
            pcall(
            function()
                v()
            end
        )
    end
end

coroutine.wrap(
    function()
        while wait(10) do
            if #queue > 0 then
                for k, v in pairs(queue) do
                    local s, e =
                        pcall(
                        function()
                            v()
                        end
                    )
                    if e or not s then
                        break
                    else
                        queue[k] = nil
                    end
                end
            end
        end
    end
)()

-- Returning everything.
return greenwich
