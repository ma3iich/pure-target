ContextMenu = {}

ContextMenu.Params = {
    EntityType = { world = 0, ped = 1, vehicle = 2, object = 3 },
    lastEntity = nil,
    lastWorldPosition = nil,
    active = false,
    menuOpen = false,
    disabled = false,
    registeredCallbacks = {},
}

local function ReleaseFocus()
    ContextMenu.Params.active = false
    SetNuiFocusKeepInput(false)
    SetNuiFocus(false, false)
    DisablePlayerFiring(PlayerId(), false)
end

-- Game actions bound to mouse buttons, disabled while the menu is open (otherwise a right-click in a
-- vehicle makes the ped aim / drive-by and breaks its own window).
-- https://docs.fivem.net/docs/game-references/controls/
-- 24 ATTACK, 25 AIM, 68 VEH_AIM, 69 VEH_ATTACK, 70 VEH_ATTACK2, 91 VEH_PASSENGER_AIM, 92 VEH_PASSENGER_ATTACK,
-- 114 VEH_FLY_ATTACK, 142 MELEE_ATTACK_ALTERNATE, 257 ATTACK2, 331 VEH_FLY_ATTACK2, 346 / 347 VEH_MELEE_LEFT / RIGHT.
local MOUSE_BUTTONS = { 24, 25, 68, 69, 70, 91, 92, 114, 142, 257, 331, 346, 347 }
-- Mouse wheel: long menus scroll with it, it must not switch weapons at the same time.
-- 14 / 15 WEAPON_WHEEL_NEXT / PREV, 16 / 17 SELECT_NEXT / PREV_WEAPON, 99 / 100 in vehicle, 261 / 262 PREV / NEXT_WEAPON.
local MOUSE_WHEEL = { 14, 15, 16, 17, 99, 100, 261, 262 }

function ContextMenu.Open()
    if ContextMenu.Params.active or ContextMenu.Params.disabled then return end
    if Config.CanOpen then
        local ok, allowed = pcall(Config.CanOpen)
        if ok and allowed == false then return end
    end
    ContextMenu.Params.active = true
    SendNUIMessage({ action = 'nui:context-menu:visible', data = true })
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(true)
    SetCursorLocation(0.5, 0.5)

    CreateThread(function()
        -- The menu stays open after a click (see ContextMenuButtonClick). It closes when the key is released,
        -- when another NUI page takes the mouse (inventory, phone...: handled by the web page, blur event),
        -- or when the game switches to another camera (scripted camera, cutscene...).
        local startCam = GetRenderingCam()
        local player = PlayerId()
        while ContextMenu.Params.active do
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            for i = 1, #MOUSE_BUTTONS do DisableControlAction(0, MOUSE_BUTTONS[i], true) end
            for i = 1, #MOUSE_WHEEL do DisableControlAction(0, MOUSE_WHEEL[i], true) end
            DisablePlayerFiring(player, true)
            if OxTargetMarkers then OxTargetMarkers.draw() end
            local cam = GetRenderingCam()
            if cam ~= startCam and cam ~= -1 then ContextMenu.Close() break end
            Wait(0)
        end
    end)
end

function ContextMenu.Close()
    ContextMenu.Params.menuOpen = false
    ReleaseFocus()
    SendNUIMessage({ action = 'nui:context-menu:visible', data = false })
end

function ContextMenu.Toggle()
    if ContextMenu.Params.active then
        ContextMenu.Close()
    else
        ContextMenu.Open()
    end
end

-- Disables the whole menu (also used by the ox_target `disableTargeting` export).
function ContextMenu.SetDisabled(state)
    ContextMenu.Params.disabled = state == true
    if ContextMenu.Params.disabled and ContextMenu.Params.active then ContextMenu.Close() end
end

function ContextMenu.IsOpen()
    return ContextMenu.Params.active
end

Keys.RegisterToggle(Config.MenuKey, 'context-menu', L('keybind'),
    function() ContextMenu.Open() end,  -- key pressed
    function() ContextMenu.Close() end  -- key released
)

local function asText(value, fallback)
    if value == nil then return fallback end
    if type(value) == 'string' then return value end
    return tostring(value)
end

local build = nil

local function newBuild()
    return {
        items = {},
        count = 0,
        header = nil,
        callbacks = {},
        checkCallbacks = {},
        closeOnClick = {},
    }
end

local function ensureBuild()
    if not build then
        build = newBuild()
    end
    return build
end

local function isCallable(v)
    local t = type(v)
    return t == 'function' or t == 'table'
end

local function parentId(parent)
    return (parent and parent > 0) and parent or nil
end

function ContextMenu.SetHeader(name, icon)
    local b = ensureBuild()
    b.header = { name = asText(name, 'Menu'), icon = icon }
end

function ContextMenu.AddSeparator(parent)
    local b = ensureBuild()
    b.count = b.count + 1
    b.items[b.count] = { id = b.count, separator = true, parent = parentId(parent) }
    return b.count
end

function ContextMenu.AddSubmenu(parent, name, icon, style, headerName, description)
    local b = ensureBuild()
    b.count = b.count + 1
    local id = b.count
    local label = asText(name, 'Submenu')
    b.items[id] = {
        id = id, name = label, icon = icon, description = description,
        style = style or {}, parent = parentId(parent),
        isSubmenu = true, headerName = asText(headerName, label:upper()),
    }
    return id
end

function ContextMenu.AddItem(parent, name, icon, style, description)
    local b = ensureBuild()
    b.count = b.count + 1
    local id = b.count
    b.items[id] = {
        id = id, name = asText(name, 'Option'), icon = icon, description = description,
        style = style or {}, parent = parentId(parent), isSubmenu = false,
    }
    return id
end

function ContextMenu.AddCheckbox(parent, name, checked, icon, style, description)
    local b = ensureBuild()
    b.count = b.count + 1
    local id = b.count
    b.items[id] = {
        id = id, name = asText(name, 'Option'), icon = icon, description = description,
        style = style or {}, parent = parentId(parent),
        isSubmenu = false, checkable = true, checked = checked or false,
    }
    return id
end

function ContextMenu.AddInfo(parent, name, value, icon, style, description)
    local b = ensureBuild()
    b.count = b.count + 1
    local id = b.count
    b.items[id] = {
        id = id, name = asText(name, 'Info'), icon = icon,
        value = value ~= nil and asText(value) or nil, description = description,
        style = style or {}, parent = parentId(parent), isSubmenu = false,
    }
    return id
end

function ContextMenu.OnActivate(id, fn)
    local b = ensureBuild()
    if id and isCallable(fn) then
        b.callbacks[id] = fn
    end
end

function ContextMenu.OnValueChanged(id, fn)
    local b = ensureBuild()
    if id and isCallable(fn) then
        b.checkCallbacks[id] = fn
    end
end

-- Every option keeps the menu open after a click, as long as the menu key is held: the menu is then
-- rebuilt at the same screen position (labels up to date, e.g. "Open" becomes "Close").
-- KeepOpen is kept for backwards compatibility and does nothing anymore.
function ContextMenu.KeepOpen(_) end

-- Option that closes the menu as soon as it is clicked (use it for actions that take the mouse without
-- opening a NUI page or a camera, e.g. a placement gizmo). ox_target: `closeOnClick = true` or `keepOpen = false`.
function ContextMenu.CloseOnClick(id)
    local b = ensureBuild()
    if id then b.closeOnClick[id] = true end
end

function ContextMenu.Register(a, b)
    local callback = a
    if not isCallable(callback) and isCallable(b) then
        callback = b
    end
    if not isCallable(callback) then
        print('^1[pure-target] Register called without a function callback^0')
        return
    end

    local owner = GetInvokingResource() or GetCurrentResourceName()
    ContextMenu.Params.nextUid = (ContextMenu.Params.nextUid or 0) + 1
    table.insert(ContextMenu.Params.registeredCallbacks, {
        owner = owner,
        fn = callback,
        uid = ContextMenu.Params.nextUid,
    })
    return ContextMenu.Params.nextUid
end

-- Removes a callback registered with Register (by the id it returned).
function ContextMenu.Unregister(uid)
    local list = ContextMenu.Params.registeredCallbacks
    for i = #list, 1, -1 do
        if list[i].uid == uid then
            table.remove(list, i)
            return true
        end
    end
    return false
end

local function purgeResource(resourceName)
    local list = ContextMenu.Params.registeredCallbacks
    for i = #list, 1, -1 do
        if list[i].owner == resourceName then
            table.remove(list, i)
        end
    end
end

AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then return end
    purgeResource(resourceName)
end)

local SerializeChildren

local function SerializeItem(b, item)
    if item.separator then
        return { id = item._globalId, separator = true }
    end

    local data = {
        id = item._globalId, name = item.name, icon = item.icon,
        style = {}, value = item.value, description = item.description,
        checkable = item.checkable, checked = item.checked,
        keepOpen = item.keepOpen or nil,
    }

    if type(item.style) == 'table' and item.style.color then
        data.style.color = item.style.color
    end

    if item.isSubmenu then
        data.child = SerializeChildren(b, item.id)
        table.insert(data.child, 1, { id = item._globalId * -1, name = item.headerName, header = true })
    end

    return data
end

function SerializeChildren(b, parentLocalId)
    local children = {}
    for lid = 1, b.count do
        local item = b.items[lid]
        if item and item.parent == parentLocalId then
            children[#children + 1] = SerializeItem(b, item)
        end
    end
    return children
end

local function BuildItems(b)
    local result = {}

    if b.header then
        result[#result + 1] = { id = 0, name = b.header.name, icon = b.header.icon, header = true }
    end

    for lid = 1, b.count do
        local item = b.items[lid]
        if item and not item.parent then
            result[#result + 1] = SerializeItem(b, item)
        end
    end

    return result
end

-- ---------------------------------------------------------------------------
-- Map objects without their own collision
-- Some vanilla props (wall ATMs, built-in furniture...) use the building's collision: the raycast returns
-- the world (type 0) instead of the prop, so addModel / addGlobalObject cannot match them. When the ray
-- hits the world, we pick the object whose bounding box is crossed by the ray, near the impact point.
-- Only runs where the raycast found no entity: props with their own collision are targeted as usual.
-- ---------------------------------------------------------------------------

-- Max distance between the impact point and the point where the ray enters the box.
local MAP_OBJECT_RANGE = 3.0
-- The building collision often sits IN FRONT of the prop's box (wall ATM: ~0.45 m), so the segment is
-- extended this far beyond the impact. Keep it short: any object closer than this behind a wall becomes selectable.
local MAP_OBJECT_THROUGH = 1.0

-- Segment / axis-aligned slab intersection (slab method).
local function SlabAxis(o, d, lo, hi, tmin, tmax)
    if math.abs(d) < 1e-6 then
        if o < lo or o > hi then return nil end
        return tmin, tmax
    end
    local t1, t2 = (lo - o) / d, (hi - o) / d
    if t1 > t2 then t1, t2 = t2, t1 end
    if t1 > tmin then tmin = t1 end
    if t2 < tmax then tmax = t2 end
    if tmin > tmax then return nil end
    return tmin, tmax
end

-- Returns t in [0, 1] (position along the segment) and the box volume, or nil if the ray misses the box.
local function RayCrossesBox(obj, p0, p1)
    local mini, maxi = GetModelDimensions(GetEntityModel(obj))
    -- Segment moved into the object's local space: the box is axis-aligned there (prop rotation handled).
    local a = GetOffsetFromEntityGivenWorldCoords(obj, p0.x, p0.y, p0.z)
    local b = GetOffsetFromEntityGivenWorldCoords(obj, p1.x, p1.y, p1.z)
    local tmin, tmax = 0.0, 1.0
    tmin, tmax = SlabAxis(a.x, b.x - a.x, mini.x, maxi.x, tmin, tmax)
    if not tmin then return nil end
    tmin, tmax = SlabAxis(a.y, b.y - a.y, mini.y, maxi.y, tmin, tmax)
    if not tmin then return nil end
    tmin, tmax = SlabAxis(a.z, b.z - a.z, mini.z, maxi.z, tmin, tmax)
    if not tmin then return nil end
    local volume = (maxi.x - mini.x) * (maxi.y - mini.y) * (maxi.z - mini.z)
    return tmin, volume
end

-- Perpendicular distance from a point to the aiming segment (tie-breaker between similar boxes).
local function DistanceToAim(center, a, b)
    local abx, aby, abz = b.x - a.x, b.y - a.y, b.z - a.z
    local ab2 = abx * abx + aby * aby + abz * abz
    if ab2 < 1e-6 then return #(center - a) end
    local apx, apy, apz = center.x - a.x, center.y - a.y, center.z - a.z
    local t = (apx * abx + apy * aby + apz * abz) / ab2
    if t < 0.0 then t = 0.0 elseif t > 1.0 then t = 1.0 end
    return #(center - vector3(a.x + abx * t, a.y + aby * t, a.z + abz * t))
end

-- The SMALLEST crossed box wins: some props have oversized boxes (prop_plant_int_01a is 3.6 x 3.6 x 2 m
-- and swallows a whole alcove), the smallest box is always the most precise target.
-- Runs on right-click only, never every frame.
local function ResolveMapObject(camPos, worldPos)
    local best, bestVolume, bestGap = 0, math.huge, math.huge
    local dir = worldPos - camPos
    local length = #dir
    if length < 1e-3 then return 0 end
    local finish = worldPos + dir * (MAP_OBJECT_THROUGH / length)
    local pool = GetGamePool('CObject')
    for i = 1, #pool do
        local obj = pool[i]
        local center = GetEntityCoords(obj)
        -- Far from the impact point: its box cannot be crossed within MAP_OBJECT_RANGE (unless > ~30 m wide).
        if #(center - worldPos) <= 20.0 then
            local t, volume = RayCrossesBox(obj, camPos, finish)
            if t then
                -- Ignore boxes crossed far in front of the impact (a prop without collision half-way).
                local pt = camPos + (finish - camPos) * t
                if #(pt - worldPos) <= MAP_OBJECT_RANGE then
                    local gap = DistanceToAim(center, camPos, worldPos)
                    -- 10 % margin: two boxes of similar size are separated by the aim, not by the volume.
                    if volume < bestVolume * 0.9 or (volume < bestVolume * 1.1 and gap < bestGap) then
                        best, bestVolume, bestGap = obj, volume, gap
                    end
                end
            end
        end
    end
    return best
end

local function RaycastScreen(screenPos, maxDistance, ignore)
    local camPos = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(0)
    local camFov = GetGameplayCamFov()
    local tempCam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', camPos.x, camPos.y, camPos.z, camRot.x, camRot.y, camRot.z, camFov, false, 2)
    local camRight, camForward, camUp, camPos2 = GetCamMatrix(tempCam)
    DestroyCam(tempCam, true)
    screenPos = vector2(screenPos.x - 0.5, screenPos.y - 0.5) * 2.0
    local fovRad = math.rad(camFov)
    local to = camPos2 + camForward + (camRight * screenPos.x * fovRad * GetAspectRatio(false) * 0.534375) - (camUp * screenPos.y * fovRad * 0.534375)
    local ep = camPos2 + (to - camPos2) * maxDistance
    local ray = StartShapeTestRay(camPos2.x, camPos2.y, camPos2.z, ep.x, ep.y, ep.z, -1, ignore or 0, 0)
    local _, hit, worldPos, _, entity = GetShapeTestResult(ray)
    if hit ~= 1 then return false, vector3(0, 0, 0), 0 end

    worldPos = vector3(worldPos.x, worldPos.y, worldPos.z)

    if entity and entity ~= 0 then
        local ok, etype = pcall(GetEntityType, entity)
        if not ok or etype == 0 or not DoesEntityExist(entity) then
            entity = ResolveMapObject(camPos2, worldPos)
        end
    else
        entity = ResolveMapObject(camPos2, worldPos)
    end

    return true, worldPos, entity
end

local activeCallbacks = {}
local activeCheckCallbacks = {}

local ignoredVehicleModels = {}
for _, model in ipairs(Config.IgnoreVehicleModels or {}) do
    local hash = type(model) == 'string' and joaat(model) or model
    ignoredVehicleModels[hash & 0xFFFFFFFF] = true
end

-- Each resource builds its entries in ITS own build, then everything is merged. Root submenus with the
-- same name (e.g. two resources adding a "Police" submenu) are merged into the first one, recursively.
local function MergeSameNameSubmenus(items)
    local byName, result = {}, {}
    for i = 1, #items do
        local it = items[i]
        local kept = it.name and it.child and byName[it.name]
        if kept then
            for j = 1, #it.child do
                local child = it.child[j]
                if not child.header then -- the kept submenu already has a header
                    kept.child[#kept.child + 1] = child
                end
            end
        else
            if it.name and it.child then byName[it.name] = it end
            result[#result + 1] = it
        end
    end
    for i = 1, #result do
        if result[i].child then
            result[i].child = MergeSameNameSubmenus(result[i].child)
        end
    end
    return result
end

RegisterNUICallback('ContextMenuPosition', function(data, cb)
    -- Menu already closed (key released, other window opened): nothing to show, even if the page still
    -- asks for the refresh that follows a click.
    if not ContextMenu.Params.active then return cb({}) end
    local px, py = tonumber(data and data.x), tonumber(data and data.y)
    if not px or not py then return cb({}) end
    local sx, sy = GetActiveScreenResolution()
    local x, y = px / sx, py / sy

    local markerZone = OxTargetMarkers and OxTargetMarkers.getAtScreen(x, y)

    local hitSomething, worldPos, entity
    if markerZone then
        hitSomething, worldPos, entity = true, markerZone.coords, 0
    else
        hitSomething, worldPos, entity = RaycastScreen(vector2(x, y), Config.RaycastDistance, nil)
    end

    ContextMenu.Params.markerZone = markerZone
    activeCallbacks = {}
    activeCheckCallbacks = {}
    ContextMenu.Params.lastEntity = entity
    ContextMenu.Params.lastWorldPosition = worldPos

    local entityType = (entity ~= 0) and GetEntityType(entity) or 0
    if entityType == 2 and ignoredVehicleModels[GetEntityModel(entity) & 0xFFFFFFFF] then entityType = 3 end
    local allItems = {}
    local globalIdCounter = 0
    local dead = {}

    for cbIndex, registered in ipairs(ContextMenu.Params.registeredCallbacks) do
        build = newBuild()
        local b = build

        local success, err = xpcall(registered.fn, function(e)
            return debug.traceback(tostring(e), 2)
        end, entity, entityType, worldPos, hitSomething)

        build = nil

        if success and b.count > 0 then
            for lid = 1, b.count do
                local item = b.items[lid]
                if item then
                    globalIdCounter = globalIdCounter + 1
                    item._globalId = globalIdCounter
                    if b.callbacks[lid] then
                        activeCallbacks[globalIdCounter] = b.callbacks[lid]
                    end
                    if b.checkCallbacks[lid] then
                        activeCheckCallbacks[globalIdCounter] = b.checkCallbacks[lid]
                    end
                    item.keepOpen = not b.closeOnClick[lid] or nil
                end
            end

            local builtItems = BuildItems(b)
            for _, builtItem in ipairs(builtItems) do
                allItems[#allItems + 1] = builtItem
            end
        elseif not success then
            dead[#dead + 1] = cbIndex
            print(('^1[pure-target] callback #%d (%s) failed and was removed:\n%s^0'):format(
                cbIndex, tostring(registered.owner), tostring(err)))
        end
    end

    for i = #dead, 1, -1 do
        table.remove(ContextMenu.Params.registeredCallbacks, dead[i])
    end

    allItems = MergeSameNameSubmenus(allItems)

    if #allItems > 0 then
        ContextMenu.Params.menuOpen = true
    end
    cb(allItems)
end)

RegisterNUICallback('ContextMenuClose', function(_, cb)
    ContextMenu.Params.menuOpen = false
    ReleaseFocus()
    SendNUIMessage({ action = 'nui:context-menu:visible', data = false })
    cb({ ok = true })
end)

RegisterNUICallback('ContextMenuButtonClick', function(data, cb)
    -- keepOpen + menu key still held: keep the cursor, the page asks for the updated menu right after.
    local keep = data.keepOpen == true and ContextMenu.Params.active
    if not keep then ReleaseFocus() end
    local callback = activeCallbacks[data.id]
    if callback then
        local ok, err = pcall(callback, ContextMenu.Params.lastEntity, ContextMenu.Params.lastWorldPosition)
        if not ok then print(('^1[pure-target] option failed: %s^0'):format(tostring(err))) end
    end
    -- Menu closed during the action (other window, camera, key released): no refresh.
    keep = keep and ContextMenu.Params.active
    cb({ ok = true, keepOpen = keep and true or false })
end)

RegisterNUICallback('ContextMenuCheckToggle', function(data, cb)
    local callback = activeCheckCallbacks[data.id]
    if callback then
        local ok, err = pcall(callback, data.checked == true, ContextMenu.Params.lastEntity, ContextMenu.Params.lastWorldPosition)
        if not ok then print(('^1[pure-target] checkbox failed: %s^0'):format(tostring(err))) end
    end
    cb({ ok = true })
end)

exports('Register', ContextMenu.Register)
exports('Unregister', ContextMenu.Unregister)
exports('SetHeader', ContextMenu.SetHeader)
exports('AddSeparator', ContextMenu.AddSeparator)
exports('AddSubmenu', ContextMenu.AddSubmenu)
exports('AddItem', ContextMenu.AddItem)
exports('AddCheckbox', ContextMenu.AddCheckbox)
exports('AddInfo', ContextMenu.AddInfo)
exports('OnActivate', ContextMenu.OnActivate)
exports('OnValueChanged', ContextMenu.OnValueChanged)
exports('KeepOpen', ContextMenu.KeepOpen)
exports('CloseOnClick', ContextMenu.CloseOnClick)
exports('Toggle', function() return ContextMenu.Toggle() end)
exports('Close', function() return ContextMenu.Close() end)
exports('IsOpen', ContextMenu.IsOpen)
exports('SetDisabled', ContextMenu.SetDisabled)

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    TriggerEvent('pure-target:ready')
end)
