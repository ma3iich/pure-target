Convert = {}

function Convert.ensureList(value)
    if type(value) == 'table' then return value end
    return { value }
end

function Convert.currentOwner()
    return GetInvokingResource() or GetCurrentResourceName()
end

local function isSingleOption(options)
    return options.name or options.label or options.onSelect or options.event or options.serverEvent
        or options.command or options.export or options.openMenu
end

-- Appends one option or a list of options to `target`, tagged with the calling resource
-- (so they are removed automatically when that resource stops).
function Convert.tableInsertList(target, options)
    if type(options) ~= 'table' then return end
    local owner = Convert.currentOwner()
    if isSingleOption(options) then
        options._owner = owner
        target[#target + 1] = options
        return
    end
    for i = 1, #options do
        if type(options[i]) == 'table' then
            options[i]._owner = owner
            target[#target + 1] = options[i]
        end
    end
end

-- New list from one option or a list of options (zones).
function Convert.ownedList(options)
    local list = {}
    Convert.tableInsertList(list, options or {})
    return list
end

function Convert.removeByNames(list, names)
    if not names then
        -- No names: only the caller's own options are removed (never other resources' options).
        local owner = Convert.currentOwner()
        for i = #list, 1, -1 do
            if list[i]._owner == owner then table.remove(list, i) end
        end
        return
    end
    local lookup = {}
    for _, n in ipairs(Convert.ensureList(names)) do lookup[n] = true end
    for i = #list, 1, -1 do
        if (list[i].name and lookup[list[i].name]) or (list[i].label and lookup[list[i].label]) then
            table.remove(list, i)
        end
    end
end

function Convert.toVec3(v)
    if v == nil then return nil end
    return vector3(v.x + 0.0, v.y + 0.0, (v.z or 0.0) + 0.0)
end

-- Answers exports['<prefix>']:<exportName>() calls (resources that call ox_target / qtarget / qb-target
-- by name: `provide` alone does not redirect exports).
function Convert.exportHandler(prefix, exportName, func)
    AddEventHandler(('__cfx_export_%s_%s'):format(prefix, exportName), function(setCB)
        setCB(func)
    end)
end

-- qtarget / qb-target options -> ox_target options.
function Convert.qtargetOptions(options)
    local distance = options.distance
    options = options.options or {}

    for k, v in pairs(options) do
        if type(k) ~= 'number' then
            table.insert(options, v)
        end
    end

    for id, v in pairs(options) do
        if type(id) ~= 'number' then
            options[id] = nil
            goto continue
        end

        -- qtarget calls action(entity) with the entity handle (see triggerOption, `qtarget = true`).
        if v.action then v.onSelect = v.action end
        v.distance = v.distance or distance
        v.name = v.name or v.label
        v.groups = v.job
        v.items = v.item or v.required_item

        -- qb-target: `gang` and `citizenid` must ALSO match (not one or the other).
        local gang, citizenid, canInteract = v.gang, v.citizenid, v.canInteract
        if gang or citizenid then
            v.canInteract = function(...)
                if gang and not Bridge.HasGroup(gang) then return false end
                if citizenid and not Bridge.HasCitizenId(citizenid) then return false end
                if canInteract then return canInteract(...) end
                return true
            end
        end

        if v.event and v.type and v.type ~= 'client' then
            if v.type == 'server' then
                v.serverEvent = v.event
            elseif v.type == 'command' then
                v.command = v.event
            end
            v.event = nil
        end

        v.type = nil
        v.action = nil
        v.job = nil
        v.gang = nil
        v.citizenid = nil
        v.item = nil
        v.required_item = nil
        v.qtarget = true

        ::continue::
    end

    return options
end
