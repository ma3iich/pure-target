-- Built-in vehicle options (natives only, no framework):
--   * the door, hood or trunk you click on: open / close it (Config.VehicleDoors);
--   * seated in the vehicle: roll windows up / down, synced to every player by the server (Config.VehicleWindows).

local MAX_BONE_DISTANCE = 2.0 -- max distance (m) between the clicked point and the bone of the part

local VEHICLE_DOORS = {
    { key = 'hood',    index = 4, icon = 'fa-solid fa-car-side',  bones = { 'bonnet' } },
    { key = 'trunk',   index = 5, icon = 'fa-solid fa-box-open',  bones = { 'boot' } },
    { key = 'door_fl', index = 0, icon = 'fa-solid fa-door-open', bones = { 'door_dside_f', 'handle_dside_f' } },
    { key = 'door_fr', index = 1, icon = 'fa-solid fa-door-open', bones = { 'door_pside_f', 'handle_pside_f' } },
    { key = 'door_rl', index = 2, icon = 'fa-solid fa-door-open', bones = { 'door_dside_r', 'handle_dside_r' } },
    { key = 'door_rr', index = 3, icon = 'fa-solid fa-door-open', bones = { 'door_pside_r', 'handle_pside_r' } },
}

-- Helicopters (15) and planes (16): door 5 is not a trunk.
local AIRCRAFT = { [15] = true, [16] = true }

local function isAircraftTrunk(entity, door)
    return door.index == 5 and AIRCRAFT[GetVehicleClass(entity)] == true
end

-- Seated in THIS vehicle, the hood / trunk is only a candidate when the click is really on it: their bone
-- ("bonnet", "boot") is the hinge, so the clicked point must be on the far side of the hinge. Otherwise
-- (door, windscreen, roof) the closest door is shown, or nothing.
local function hoodTrunkNotAimed(entity, door, worldPos)
    if door.index ~= 4 and door.index ~= 5 then return false end
    if GetVehiclePedIsIn(PlayerPedId(), false) ~= entity then return false end
    local bone = GetEntityBoneIndexByName(entity, door.bones[1])
    if bone == -1 then return false end
    local hinge = GetOffsetFromEntityGivenWorldCoords(entity, GetWorldPositionOfEntityBone(entity, bone))
    local aimed = GetOffsetFromEntityGivenWorldCoords(entity, worldPos.x, worldPos.y, worldPos.z)
    -- hood at the front (or rear-engine), trunk at the rear (or front): the end is on the hinge side
    local towardsEnd = hinge.y >= 0.0 and 1.0 or -1.0
    return (aimed.y - hinge.y) * towardsEnd < -0.1
end

-- Closest part to the clicked point (nil if too far), and whether the model has any usable bone.
local function getAimedDoor(entity, worldPos)
    local best, bestDist = nil, nil
    local anyBone = false

    for _, door in ipairs(VEHICLE_DOORS) do
        if GetIsDoorValid(entity, door.index) and not isAircraftTrunk(entity, door)
            and not hoodTrunkNotAimed(entity, door, worldPos) then
            for _, boneName in ipairs(door.bones) do
                local boneIndex = GetEntityBoneIndexByName(entity, boneName)
                if boneIndex ~= -1 then
                    anyBone = true
                    local dist = #(worldPos - GetWorldPositionOfEntityBone(entity, boneIndex))
                    if not bestDist or dist < bestDist then
                        bestDist, best = dist, door
                    end
                end
            end
        end
    end

    if best and bestDist <= MAX_BONE_DISTANCE then
        return best, anyBone
    end
    return nil, anyBone
end

-- Locked vehicle (lock status >= 2): parts cannot be OPENED from outside. Closing an open part is still
-- allowed. Exceptions: the player sits in the vehicle, or only the trunk is unlocked (status 8).
local function isLockedFor(entity, door)
    local status = GetVehicleDoorLockStatus(entity)
    if status < 2 then return false end
    if status == 8 and door.index == 5 then return false end
    return GetVehiclePedIsIn(PlayerPedId(), false) ~= entity
end

local function addDoorItem(entity, door)
    local isOpen = GetVehicleDoorAngleRatio(entity, door.index) > 0.1
    local name = L(door.key)

    if not isOpen and isLockedFor(entity, door) then
        ContextMenu.AddItem(0, L('locked', name), 'fa-solid fa-lock', { color = { 150, 150, 150 } }, L('locked_desc'))
        return
    end

    local id = ContextMenu.AddItem(0, L(isOpen and 'close' or 'open', name), isOpen and 'fa-solid fa-door-closed' or door.icon)
    ContextMenu.OnActivate(id, function(ent)
        if not DoesEntityExist(ent) then return end
        if isOpen then
            SetVehicleDoorShut(ent, door.index, false)
        elseif not isLockedFor(ent, door) then -- may have been locked since the menu opened
            SetVehicleDoorOpen(ent, door.index, false, false)
        end
    end)
end

-- Windows ----------------------------------------------------------------------
-- The server checks the request and stores the state in the vehicle's `puretarget:windows` state bag:
-- { m = mask (bit i = window i rolled down), n = counter }, applied by every client.

local WINDOWS = { -- index = door index = window index
    [0] = { key = 'window_fl', bone = 'window_lf' },
    [1] = { key = 'window_fr', bone = 'window_rf' },
    [2] = { key = 'window_rl', bone = 'window_lr' },
    [3] = { key = 'window_rr', bone = 'window_rr' },
}
local STATE_KEY = 'puretarget:windows'

local function windowMask(state)
    if type(state) == 'table' and math.type(state.m) == 'integer' then return state.m & 15 end
    return 0
end

-- Windows the player may use in this vehicle (nil when not seated in it).
-- Driver (seat -1): all of them; passenger in seat 0, 1, 2: window 1, 2, 3.
local function allowedWindows(entity)
    local ped = PlayerPedId()
    if GetVehiclePedIsIn(ped, false) ~= entity then return nil end
    if GetPedInVehicleSeat(entity, -1) == ped then return { [0] = true, [1] = true, [2] = true, [3] = true } end
    for seat = 0, 2 do
        if GetPedInVehicleSeat(entity, seat) == ped then return { [seat + 1] = true } end
    end
    return nil
end

local function addWindowsSubmenu(entity)
    local allowed = allowedWindows(entity)
    if not allowed then return end
    local mask = windowMask(Entity(entity).state[STATE_KEY])
    local menu
    for i = 0, 3 do
        if allowed[i] and GetEntityBoneIndexByName(entity, WINDOWS[i].bone) ~= -1 then
            menu = menu or ContextMenu.AddSubmenu(0, L('windows'), 'fa-solid fa-window-maximize')
            local down = (mask >> i) & 1 == 1
            local id = ContextMenu.AddItem(menu, L(down and 'roll_up' or 'roll_down', L(WINDOWS[i].key)),
                down and 'fa-solid fa-arrow-up' or 'fa-solid fa-arrow-down')
            ContextMenu.OnActivate(id, function(ent)
                if not DoesEntityExist(ent) or not NetworkGetEntityIsNetworked(ent) then return end
                TriggerServerEvent('pure-target:window', NetworkGetNetworkIdFromEntity(ent), i, not down)
            end)
        end
    end
end

-- Only windows rolled down by this system are rolled up again (never a broken window or one handled
-- by another script).
local function applyWindows(veh, mask, previous)
    for i = 0, 3 do
        local bit = 1 << i
        if mask & bit ~= 0 then
            RollDownWindow(veh, i)
        elseif previous & bit ~= 0 then
            RollUpWindow(veh, i)
        end
    end
end

if Config.VehicleWindows then
    -- During the handler, the state bag still holds the PREVIOUS value (FiveM docs).
    AddStateBagChangeHandler(STATE_KEY, nil, function(bagName, _, value)
        if type(value) ~= 'table' or math.type(value.m) ~= 'integer' then return end
        local veh = GetEntityFromStateBagName(bagName)
        if veh ~= 0 then
            applyWindows(veh, value.m & 15, windowMask(Entity(veh).state[STATE_KEY]))
            return
        end
        -- Vehicle coming into scope: its state bag sometimes arrives before the entity.
        CreateThread(function()
            local timeout = GetGameTimer() + 3000
            repeat
                Wait(100)
                veh = GetEntityFromStateBagName(bagName)
            until veh ~= 0 or GetGameTimer() > timeout
            if veh ~= 0 then applyWindows(veh, windowMask(Entity(veh).state[STATE_KEY]), 0) end
        end)
    end)
end

-- Menu -------------------------------------------------------------------------

if Config.VehicleDoors or Config.VehicleWindows then
    ContextMenu.Register(function(entity, entityType, worldPos, hit)
        if entityType ~= 2 or not hit then return end
        if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(entity)) > 5.0 then return end

        if Config.VehicleDoors then
            local aimed, anyBone = getAimedDoor(entity, worldPos)
            if aimed then
                addDoorItem(entity, aimed)
            elseif not anyBone then
                -- Model without usable bones: every part is listed.
                for _, door in ipairs(VEHICLE_DOORS) do
                    if GetIsDoorValid(entity, door.index) and not isAircraftTrunk(entity, door) then
                        addDoorItem(entity, door)
                    end
                end
            end
            -- (bones exist but no part is aimed at, e.g. roof or fender: no door option)
        end

        if Config.VehicleWindows then
            addWindowsSubmenu(entity)
        end
    end)
end
