--Variables
local dss = game:GetService("DataStoreService")

-- Tables
local greenwich = {}
local dbFunctions = {}

--Functions
function greenwich:GetDB(name)
    local db = dss:GetDataStore(name)
    local new = {}
    new.store = db
    coroutine.resume(coroutine.create(function()
        for k, v in ipairs(dbFunctions) do
            new[k] = function(...)

                local args = { ... }
                v(new.store, unpack(args))

            end

        end
    end))
    return new
end

function dbFunctions:Set(store, key, value)
    return value
end

--Returning everything.
return greenwich
