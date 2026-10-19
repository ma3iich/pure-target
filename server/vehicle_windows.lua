-- Vehicle windows rolled up / down from the menu (client/modules/vehicle_doors.lua).
-- The server checks the request, then stores the state in the vehicle's `puretarget:windows` state bag:
-- { m = mask (bit i = window i rolled down), n = counter }, applied by every client.
-- Why not the game sync: it only comes from the client that "owns" the vehicle (usually the driver);
-- a window rolled down by a passenger would only be seen by that passenger.
-- The counter changes on every request, so the order is resent even when the mask does not change.

if not Config.VehicleWindows then return end

local STATE_KEY = 'puretarget:windows'
local MIN_DELAY = 250 -- ms between two requests from the same player
local nextRequest = {}

RegisterNetEvent('pure-target:window', function(netId, window, rollDown)
    local src = source
    if math.type(netId) ~= 'integer' or math.type(window) ~= 'integer' or type(rollDown) ~= 'boolean' then return end
    if window < 0 or window > 3 then return end

    local now = GetGameTimer()
    if (nextRequest[src] or 0) > now then return end
    nextRequest[src] = now + MIN_DELAY

    local veh = NetworkGetEntityFromNetworkId(netId)
    if veh == 0 or not DoesEntityExist(veh) or GetEntityType(veh) ~= 2 then return end

    -- Seated in THIS vehicle: the driver handles every window, the passenger in seat 0, 1 or 2 only
    -- window 1, 2 or 3 (seat = window - 1; window 0 belongs to the driver).
    local ped = GetPlayerPed(src)
    if ped == 0 or GetVehiclePedIsIn(ped, false) ~= veh then return end
    if GetPedInVehicleSeat(veh, -1) ~= ped and GetPedInVehicleSeat(veh, window - 1) ~= ped then return end

    local state = Entity(veh).state[STATE_KEY]
    local mask = (type(state) == 'table' and math.type(state.m) == 'integer') and state.m & 15 or 0
    local n = (type(state) == 'table' and math.type(state.n) == 'integer') and state.n or 0
    local bit = 1 << window
    mask = rollDown and (mask | bit) or (mask & ~bit)
    Entity(veh).state:set(STATE_KEY, { m = mask, n = (n + 1) % 1000000 }, true)
end)

AddEventHandler('playerDropped', function()
    nextRequest[source] = nil
end)
