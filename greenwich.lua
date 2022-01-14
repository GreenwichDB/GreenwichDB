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
    for _k, v in pairs(queue) do
        local _s, _e =
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

game:BindToClose(function()
	print("[GREENWICHDB/QUEUE] The queue is now ending to ensure that no data is lost.")
	greenwich:EndQueue()
end)

--[[
    An issue was recently brought up that sometimes the cache was not being updated.
    To reproduce it:
    Join server A
    Leave server A
    Join server B
    Make some change in the cache
    Leave server B
    Join server A
    As a result of this, you will see the cache not being updated.
    This fixes it by automatically saving and then just removing them from the cache.
]]--

game:GetService("Players").PlayerRemoving:Connect(function(player)
    for k: string, _v in pairs(cache) do -- iterate through the cache
        if string.find(k, player.UserId) then -- check if the key contains the id of the player who left
            local store = k:gsub(player.UserId, "") -- get the store name from the key
            local key = k:gsub(store, "") -- get the key it was saved to
            db:SetAsync(store .. key, cache[store .. key]) -- save data
            cache[k] = nil -- remove from cache
        end
        -- now, we simply repeat this but instead we check for the name
        if string.find(k, player.Name) then -- check if the key contains the name of the player who left
            local store = k:gsub(player.Name, "") -- get the store name from the key
            local key = k:gsub(store, "") -- get the key it was saved to
            db:SetAsync(store .. key, cache[store .. key]) -- save data
            cache[k] = nil -- remove from cache
        end
    end
end)

-- Returning everything.
return greenwich