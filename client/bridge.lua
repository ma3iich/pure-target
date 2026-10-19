-- Framework bridge for the `groups` and `items` filters of ox_target / qtarget options.
-- Everything is resolved lazily (on right-click), so the framework may start before or after pure-target.
-- Nothing here runs every frame.

Bridge = {}

local function started(name)
    return GetResourceState(name) == 'started'
end

local detected
local function framework()
    if detected then return detected end
    local wanted = Config.Framework or 'auto'
    if wanted ~= 'auto' then
        detected = wanted
    elseif started('qbx_core') then
        detected = 'qbx'
    elseif started('qb-core') then
        detected = 'qb'
    elseif started('es_extended') then
        detected = 'esx'
    else
        -- Not cached: a framework that is still starting will be picked up on the next click.
        return 'none'
    end
    return detected
end

local QBCore, ESX
local function playerData()
    local fw = framework()
    if fw == 'qbx' then
        return exports.qbx_core:GetPlayerData()
    elseif fw == 'qb' then
        QBCore = QBCore or exports['qb-core']:GetCoreObject()
        return QBCore.Functions.GetPlayerData()
    elseif fw == 'esx' then
        ESX = ESX or exports.es_extended:getSharedObject()
        return ESX.GetPlayerData()
    end
end

-- Player groups as { [name] = grade }.
local function playerGroups()
    local ok, data = pcall(playerData)
    if not ok or type(data) ~= 'table' then return {} end
    local groups = {}
    local function add(group)
        if type(group) ~= 'table' or not group.name then return end
        local grade = group.grade
        if type(grade) == 'table' then grade = grade.level end -- qb / qbx
        groups[group.name] = tonumber(grade) or 0
    end
    add(data.job)
    add(data.job2) -- esx job2
    add(data.gang) -- qb / qbx
    return groups
end

local warned = false

-- filter: 'police' | { 'police', 'ambulance' } | { police = 2, ambulance = 0 } (minimum grade)
function Bridge.HasGroup(filter)
    if Config.HasGroup then
        local ok, result = pcall(Config.HasGroup, filter)
        return ok and result == true
    end
    if framework() == 'qbx' then
        local ok, result = pcall(function() return exports.qbx_core:HasGroup(filter) end)
        if ok then return result and true or false end
    end
    if framework() == 'none' then
        if not warned then
            warned = true
            print('^3[pure-target] An option uses `groups` but no framework was found: it stays hidden. '
                .. 'Set Config.Framework or Config.HasGroup in shared/config.lua.^0')
        end
        return false
    end

    local groups = playerGroups()
    local kind = type(filter)
    if kind == 'string' then
        return groups[filter] ~= nil
    elseif kind == 'table' then
        if filter[1] ~= nil then
            for i = 1, #filter do
                if groups[filter[i]] ~= nil then return true end
            end
        else
            for name, minGrade in pairs(filter) do
                local grade = groups[name]
                if grade and grade >= (tonumber(minGrade) or 0) then return true end
            end
        end
    end
    return false
end

-- qb-target `citizenid` filter: 'ABC123' | { 'ABC123', 'DEF456' } | { ABC123 = true }
function Bridge.HasCitizenId(filter)
    local ok, data = pcall(playerData)
    if not ok or type(data) ~= 'table' then return false end
    local id = data.citizenid or data.identifier -- qb / qbx, esx
    if not id then return false end
    if type(filter) == 'string' then return filter == id end
    if type(filter) == 'table' then
        if filter[id] then return true end
        for i = 1, #filter do
            if filter[i] == id then return true end
        end
    end
    return false
end

-- Item counts from the framework inventory (used when ox_inventory is not running).
local function frameworkItemCount(name)
    local ok, data = pcall(playerData)
    if not ok or type(data) ~= 'table' then return 0 end
    local list = data.items or data.inventory -- qb / esx
    if type(list) ~= 'table' then return 0 end
    local count = 0
    for _, item in pairs(list) do
        if type(item) == 'table' and item.name == name then
            count = count + (tonumber(item.amount or item.count) or 0)
        end
    end
    return count
end

function Bridge.GetItemCount(name)
    if Config.GetItemCount then
        local ok, count = pcall(Config.GetItemCount, name)
        return ok and tonumber(count) or 0
    end
    if started('ox_inventory') then
        local ok, count = pcall(function() return exports.ox_inventory:GetItemCount(name) end)
        return ok and tonumber(count) or 0
    end
    return frameworkItemCount(name)
end

-- filter: 'lockpick' | { 'lockpick', 'screwdriver' } | { lockpick = 2 }; anyItem = one of them is enough.
function Bridge.HasItems(filter, anyItem)
    local kind = type(filter)
    if kind == 'string' then
        return Bridge.GetItemCount(filter) > 0
    elseif kind ~= 'table' then
        return true
    end

    local isArray = filter[1] ~= nil
    for key, value in pairs(filter) do
        local name, need = key, tonumber(value) or 1
        if isArray then name, need = value, 1 end
        local has = Bridge.GetItemCount(name) >= need
        if anyItem then
            if has then return true end
        elseif not has then
            return false
        end
    end
    return not anyItem
end
