-- Variables
local dss = game:GetService("DataStoreService")
local db = dss:GetDataStore("Greenwich")

-- Tables
local greenwich = {}
greenwich.__index = greenwich

local cache = {}
local queue = {}

-- Helper function

function addToQueue(fn)
    queue[os.time()] = fn
end

-- Functions
function greenwich.GetDB(name)
    local new = setmetatable({}, greenwich)
    new.name = name

    return new
end

function greenwich:Set(key, value, shouldSave)
    local store = self.name
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

function greenwich:Get(key)
    local store = self.name
    if not (not cache[store .. key]) then
        return cache[store .. key]
    else
        local val = db:GetAsync(store .. key)
        cache[store .. key] = val
        return val
    end
end

function greenwich:Delete(key)
    local store = self.name
    addToQueue(
        function()
            db:RemoveAsync(store .. key)
        end
    )
    cache[store .. key] = nil
    return true
end

function greenwich:Has(key)
    local store = self.name
    if not (not cache[store .. key]) then
        return not (not cache[store .. key])
    else
        return not (not db:GetAsync(store .. key))
    end
end

function greenwich:Save(key)
    local store = self.name
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

function greenwich:Fetch(key)
    local store = self.name
    addToQueue(
        function()
            local value = db:GetAsync(store .. key)
            cache[store .. key] = value
        end
    )
    return true
end

function greenwich.EndQueue()
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

-- Returning everything.
return greenwich
