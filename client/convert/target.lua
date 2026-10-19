-- ox_target compatibility: option store, matching and actions.
-- Matching follows ox_target's own rules (distance, groups, items, bones, offset, canInteract), so existing
-- scripts behave the same. Everything here runs on right-click only, except the zone markers (drawn while
-- the menu is open).

OxTarget = {}

local globalOtherPlayer = {}
local globalSelfPlayer = {}
local globalPlayer = {}
local globalPed = {}
local globalVehicle = {}
local globalObject = {}
local globalOptions = {}
local models = {}
local localEntities = {}
local networkEntities = {}
local zones = {}

local zoneIdCounter = 0
local targetingDisabled = false

local ensureList = Convert.ensureList
local tableInsertList = Convert.tableInsertList
local removeByNames = Convert.removeByNames
local toVec3 = Convert.toVec3

local function resolveModelKey(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return nil end
    local ok, model = pcall(GetEntityModel, entity)
    if not ok then return nil end
    return model
end

-- `bones` field: the option is shown only when the click is close to one of these bones (ox_target rules).
-- Returns the bone index (or true when the option has no bones), nil when the option must be hidden.
local function matchBones(option, entity, coords)
    local bones = option.bones
    if not bones then return true end
    if not entity or entity == 0 then return nil end

    if type(bones) == 'string' then
        local boneId = GetEntityBoneIndexByName(entity, bones)
        if boneId ~= -1 and #(coords - GetEntityBonePosition_2(entity, boneId)) <= 2.0 then return boneId end
        return nil
    end

    local closest, closestDist
    for i = 1, #bones do
        local boneId = GetEntityBoneIndexByName(entity, bones[i])
        if boneId ~= -1 then
            local dist = #(coords - GetEntityBonePosition_2(entity, boneId))
            if dist <= (closestDist or 1.0) then
                closest, closestDist = boneId, dist
            end
        end
    end
    return closest
end

-- `offset` field: the click must be within `offsetSize` (default 1 m) of a point of the entity.
-- `offset` is relative to the model size (0..1) unless `absoluteOffset = true`.
local function matchOffset(option, entity, coords)
    local offset = option.offset
    if not offset then return true end
    if not entity or entity == 0 then return false end
    offset = toVec3(offset)
    if not option.absoluteOffset then
        local min, max = GetModelDimensions(GetEntityModel(entity))
        offset = (max - min) * offset + min
    end
    local point = GetOffsetFromEntityInWorldCoords(entity, offset.x, offset.y, offset.z)
    return #(coords - point) <= (option.offsetSize or 1.0)
end

-- Same as ox_target: hidden when canInteract errors or returns a falsy value (nil included).
local function isVisible(option, entity, distance, coords)
    if distance > (option.distance or Config.DefaultDistance) then return false end
    if option.groups and not Bridge.HasGroup(option.groups) then return false end
    if option.items and not Bridge.HasItems(option.items, option.anyItem) then return false end

    local bone = matchBones(option, entity, coords)
    if not bone then return false end
    if bone == true then bone = nil end

    if not matchOffset(option, entity, coords) then return false end

    if option.canInteract then
        local ok, result = pcall(option.canInteract, entity, distance, coords, option.name, bone)
        return ok and result and true or false
    end
    return true
end

-- Data passed to the option's action, built like ox_target's getResponse.
local function buildResponse(option, entity, coords, distance, zoneId, forServer)
    local response = {}
    for k, v in pairs(option) do response[k] = v end
    response.entity = entity or 0
    response.coords = coords
    response.distance = distance
    response.zone = zoneId

    if forServer then
        response.entity = (response.entity ~= 0 and NetworkGetEntityIsNetworked(response.entity))
            and NetworkGetNetworkIdFromEntity(response.entity) or 0
    end

    response.icon = nil
    response.groups = nil
    response.items = nil
    response.canInteract = nil
    response.onSelect = nil
    response.export = nil
    response.event = nil
    response.serverEvent = nil
    response.command = nil
    response._owner = nil
    return response
end

local function triggerOption(option, entity, coords, zoneId)
    local distance = #(GetEntityCoords(PlayerPedId()) - coords)

    if option.onSelect then
        -- qtarget `action` receives the entity handle, ox_target `onSelect` receives the response table.
        option.onSelect(option.qtarget and entity or buildResponse(option, entity, coords, distance, zoneId))
    elseif option.export then
        -- ox_target: export = 'method' (+ resource = 'name', defaults to the registering resource).
        -- Also accepted: export = 'resource.method'.
        local resource, method = option.export:match('^([^%.]+)%.([^%.]+)$')
        if not resource then resource, method = option.resource or option._owner, option.export end
        if resource and method then
            exports[resource][method](nil, buildResponse(option, entity, coords, distance, zoneId))
        end
    elseif option.event then
        TriggerEvent(option.event, buildResponse(option, entity, coords, distance, zoneId))
    elseif option.serverEvent then
        TriggerServerEvent(option.serverEvent, buildResponse(option, entity, coords, distance, zoneId, true))
    elseif option.command then
        ExecuteCommand(option.command)
    end
end

local function collectOptions(out, list, entity, coords, distance, zoneId)
    for i = 1, #list do
        local option = list[i]
        if isVisible(option, entity, distance, coords) then
            out[#out + 1] = { option = option, zone = zoneId }
        end
    end
end

-- The menu only accepts { R, G, B }: hex colours ('#f59e0b') are converted.
local function toRgb(c)
    if type(c) ~= 'string' then return c end
    local hex = c:match('^#?(%x%x%x%x%x%x)$')
    if not hex then return nil end
    return { tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16) }
end

ContextMenu.Register(function(entity, entityType, worldPos, hit)
    if targetingDisabled or not hit then return end

    local distance = #(GetEntityCoords(PlayerPedId()) - worldPos)
    local matched = {}

    if entity and entity ~= 0 and DoesEntityExist(entity) then
        local model = resolveModelKey(entity)

        if model and models[model] then
            collectOptions(matched, models[model], entity, worldPos, distance)
        end

        if NetworkGetEntityIsNetworked(entity) then
            local netId = NetworkGetNetworkIdFromEntity(entity)
            if networkEntities[netId] then
                collectOptions(matched, networkEntities[netId], entity, worldPos, distance)
            end
        end

        if localEntities[entity] then
            collectOptions(matched, localEntities[entity], entity, worldPos, distance)
        end

        if entityType == 1 then
            if IsPedAPlayer(entity) then
                if entity == PlayerPedId() then
                    collectOptions(matched, globalSelfPlayer, entity, worldPos, distance)
                else
                    collectOptions(matched, globalOtherPlayer, entity, worldPos, distance)
                end
                collectOptions(matched, globalPlayer, entity, worldPos, distance)
            else
                collectOptions(matched, globalPed, entity, worldPos, distance)
            end
        elseif entityType == 2 then
            collectOptions(matched, globalVehicle, entity, worldPos, distance)
        elseif entityType == 3 then
            collectOptions(matched, globalObject, entity, worldPos, distance)
        end
    end

    for id, zone in pairs(zones) do
        if zone:contains(worldPos) then
            collectOptions(matched, zone.options, entity, worldPos, distance, id)
        end
    end

    collectOptions(matched, globalOptions, entity, worldPos, distance)

    if #matched == 0 then return end

    -- Submenus:
    --   * `group = 'Police'` (pure-target extension): options sharing a group are put in a submenu
    --     (`groupIcon`, `groupColor` optional).
    --   * ox_target nested menus: an option with `openMenu = 'x'` becomes a submenu holding the options
    --     that have `menuName = 'x'`.
    local groupMenus, namedMenus = {}, {}

    for i = 1, #matched do
        local option = matched[i].option
        if option.openMenu and not namedMenus[option.openMenu] then
            local style = option.iconColor and { color = toRgb(option.iconColor) } or nil
            namedMenus[option.openMenu] = ContextMenu.AddSubmenu(0, option.label or option.name or 'Menu', option.icon, style)
        end
    end

    local function parentFor(option)
        if option.menuName then
            return namedMenus[option.menuName] -- nil: its opening option is not shown, hide it too
        end
        local g = option.group
        if not g then return 0 end
        if not groupMenus[g] then
            local style = option.groupColor and { color = toRgb(option.groupColor) } or nil
            groupMenus[g] = ContextMenu.AddSubmenu(0, g, option.groupIcon or 'fa-solid fa-layer-group', style)
        end
        return groupMenus[g]
    end

    for i = 1, #matched do
        local option, zoneId = matched[i].option, matched[i].zone
        local parent = not option.openMenu and parentFor(option)
        if parent then
            local style = option.iconColor and { color = toRgb(option.iconColor) } or nil
            local id = ContextMenu.AddItem(parent, option.label or option.name or 'Option', option.icon, style, option.description)
            if option.closeOnClick or option.keepOpen == false then ContextMenu.CloseOnClick(id) end
            ContextMenu.OnActivate(id, function(ent, coords)
                triggerOption(option, ent, coords or worldPos, zoneId)
            end)
        end
    end
end)

function OxTarget.addGlobalPlayer(options) tableInsertList(globalPlayer, options) end
function OxTarget.addGlobalSelfPlayer(options) tableInsertList(globalSelfPlayer, options) end
function OxTarget.addGlobalOtherPlayer(options) tableInsertList(globalOtherPlayer, options) end
function OxTarget.addGlobalPed(options) tableInsertList(globalPed, options) end
function OxTarget.addGlobalVehicle(options) tableInsertList(globalVehicle, options) end
function OxTarget.addGlobalObject(options) tableInsertList(globalObject, options) end
function OxTarget.addGlobalOption(options) tableInsertList(globalOptions, options) end

function OxTarget.removeGlobalPlayer(names) removeByNames(globalPlayer, names) end
function OxTarget.removeGlobalSelfPlayer(names) removeByNames(globalSelfPlayer, names) end
function OxTarget.removeGlobalOtherPlayer(names) removeByNames(globalOtherPlayer, names) end
function OxTarget.removeGlobalPed(names) removeByNames(globalPed, names) end
function OxTarget.removeGlobalVehicle(names) removeByNames(globalVehicle, names) end
function OxTarget.removeGlobalObject(names) removeByNames(globalObject, names) end
function OxTarget.removeGlobalOption(names) removeByNames(globalOptions, names) end

function OxTarget.addModel(input, options)
    for _, m in ipairs(ensureList(input)) do
        local key = type(m) == 'string' and joaat(m) or m
        models[key] = models[key] or {}
        tableInsertList(models[key], options)
    end
end

function OxTarget.removeModel(input, names)
    for _, m in ipairs(ensureList(input)) do
        local key = type(m) == 'string' and joaat(m) or m
        if models[key] then removeByNames(models[key], names) end
    end
end

function OxTarget.addEntity(input, options)
    for _, netId in ipairs(ensureList(input)) do
        networkEntities[netId] = networkEntities[netId] or {}
        tableInsertList(networkEntities[netId], options)
    end
end

function OxTarget.removeEntity(input, names)
    for _, netId in ipairs(ensureList(input)) do
        if networkEntities[netId] then removeByNames(networkEntities[netId], names) end
    end
end

function OxTarget.addLocalEntity(input, options)
    for _, ent in ipairs(ensureList(input)) do
        localEntities[ent] = localEntities[ent] or {}
        tableInsertList(localEntities[ent], options)
    end
end

function OxTarget.removeLocalEntity(input, names)
    for _, ent in ipairs(ensureList(input)) do
        if localEntities[ent] then removeByNames(localEntities[ent], names) end
    end
end

local function registerZone(zone, params)
    zoneIdCounter = zoneIdCounter + 1
    zone.id = zoneIdCounter
    zone.name = params.name
    zone.options = Convert.ownedList(params.options)
    -- markerCoords: where the marker is drawn when it differs from the zone centre (qtarget zones).
    zone.coords = toVec3(params.markerCoords or params.coords or zone.coords)
    zone.marker = params.drawSprite ~= false and params.marker ~= false
    zone.markerRadius = params.markerRadius or Config.MarkerClickRadius
    zone.markerColor = params.markerColor
    zone.distance = params.markerDistance or params.distance or Config.MarkerDrawDistance
    zone._owner = Convert.currentOwner()
    zones[zoneIdCounter] = zone
    return zoneIdCounter
end

function OxTarget.addSphereZone(params)
    local coords = toVec3(params.coords)
    local radius = params.radius or 2.0
    local zone = {
        coords = coords,
        contains = function(_, point) return #(coords - point) <= radius end,
    }
    return registerZone(zone, params)
end

function OxTarget.addBoxZone(params)
    local coords = toVec3(params.coords)
    local size = toVec3(params.size or vector3(2.0, 2.0, 2.0))
    local half = size / 2.0
    local rad = math.rad(params.rotation or 0.0)
    local cosR, sinR = math.cos(rad), math.sin(rad)
    local zone = {
        coords = coords,
        contains = function(_, point)
            local d = point - coords
            -- Point moved into the box's rotated frame (rotation around Z).
            local lx = d.x * cosR + d.y * sinR
            local ly = -d.x * sinR + d.y * cosR
            return math.abs(lx) <= half.x and math.abs(ly) <= half.y and math.abs(d.z) <= half.z
        end,
    }
    return registerZone(zone, params)
end

-- z of a point given as vector2 / vector3 / table (vector2 has no z).
local function zOf(p)
    local t = type(p)
    if t == 'vector3' or t == 'vector4' or t == 'table' then return p.z or 0.0 end
    return 0.0
end

function OxTarget.addPolyZone(params)
    local points = params.points
    local thickness = params.thickness or 4.0
    local minZ = params.minZ
    local maxZ = params.maxZ

    local center = toVec3(params.coords)
    if not center and points and #points > 0 then
        local sx, sy, sz = 0.0, 0.0, 0.0
        for i = 1, #points do
            sx, sy, sz = sx + points[i].x, sy + points[i].y, sz + zOf(points[i])
        end
        center = vector3(sx / #points, sy / #points, sz / #points)
    end
    if not minZ and center then minZ = center.z - thickness / 2 end
    if not maxZ and center then maxZ = center.z + thickness / 2 end

    local zone = {
        coords = center,
        contains = function(_, point)
            if minZ and point.z < minZ then return false end
            if maxZ and point.z > maxZ then return false end
            local inside = false
            local j = #points
            for i = 1, #points do
                local pi, pj = points[i], points[j]
                if ((pi.y > point.y) ~= (pj.y > point.y))
                    and (point.x < (pj.x - pi.x) * (point.y - pi.y) / (pj.y - pi.y) + pi.x) then
                    inside = not inside
                end
                j = i
            end
            return inside
        end,
    }
    return registerZone(zone, params)
end

-- id = number returned by add*Zone, or the zone `name`.
function OxTarget.removeZone(id)
    if type(id) == 'string' then
        for zoneId, zone in pairs(zones) do
            if zone.name == id then zones[zoneId] = nil end
        end
        return
    end
    zones[id] = nil
end

function OxTarget.zoneExists(id)
    if type(id) == 'string' then
        for _, zone in pairs(zones) do
            if zone.name == id then return true end
        end
        return false
    end
    return zones[id] ~= nil
end

-- Zone markers ----------------------------------------------------------------

local markerDict, markerTexture = 'shared', 'emptydot_32'
local markerSpriteReady = false

local function ensureMarkerTexture()
    if markerSpriteReady then return true end
    if not HasStreamedTextureDictLoaded(markerDict) then
        RequestStreamedTextureDict(markerDict, false)
        return false
    end
    markerSpriteReady = true
    return true
end

local function getMarkerScreenPos(zone, playerCoords)
    local coords = zone.coords
    if not coords then return false, 0.0, 0.0 end
    if #(playerCoords - coords) > (zone.distance or Config.MarkerDrawDistance) then return false, 0.0, 0.0 end
    local onScreen, sx, sy = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)
    return onScreen, sx, sy
end

local function markerColor(zone)
    local c = zone.markerColor
    if not c then return 155, 155, 155, 175 end
    return c[1] or c.r or 155, c[2] or c.g or 155, c[3] or c.b or 155, c[4] or c.a or 175
end

-- Markers are drawn every frame while the menu is open. Only zones close enough are tested every frame;
-- that short list is refreshed every 250 ms. SORT_MARGIN: what a fast vehicle travels in 250 ms.
local SORT_MARGIN, SORT_DELAY = 15.0, 250
local nearbyZones, nextSort = {}, 0

local function sortNearbyZones(playerCoords)
    local list, n = {}, 0
    for _, zone in pairs(zones) do
        if zone.marker and zone.coords
            and #(playerCoords - zone.coords) <= (zone.distance or Config.MarkerDrawDistance) + SORT_MARGIN then
            n = n + 1
            list[n] = zone
        end
    end
    nearbyZones = list
end

function OxTarget.drawZoneMarkers()
    if targetingDisabled or not ensureMarkerTexture() then return end

    local playerCoords = GetEntityCoords(PlayerPedId())
    local width = 0.014
    local height = width * GetAspectRatio(false)

    local now = GetGameTimer()
    if now >= nextSort then
        nextSort = now + SORT_DELAY
        sortNearbyZones(playerCoords)
    end

    for i = 1, #nearbyZones do
        local zone = nearbyZones[i]
        -- zones[zone.id] == zone: the zone may have been removed since the last sort
        if zones[zone.id] == zone and #zone.options > 0 then
            local onScreen, sx, sy = getMarkerScreenPos(zone, playerCoords)
            if onScreen then
                local r, g, b, a = markerColor(zone)
                DrawSprite(markerDict, markerTexture, sx, sy, width, height, 0.0, r, g, b, a)
            end
        end
    end
end

function OxTarget.getMarkerAtScreen(nx, ny)
    if targetingDisabled then return nil end

    local playerCoords = GetEntityCoords(PlayerPedId())
    local sw, sh = GetActiveScreenResolution()
    local cursorX, cursorY = nx * sw, ny * sh

    local best, bestDist
    for _, zone in pairs(zones) do
        if zone.marker and zone.coords and #zone.options > 0 then
            local onScreen, sx, sy = getMarkerScreenPos(zone, playerCoords)
            if onScreen then
                local dx, dy = sx * sw - cursorX, sy * sh - cursorY
                local pixelDist = math.sqrt(dx * dx + dy * dy)
                if pixelDist <= (zone.markerRadius or Config.MarkerClickRadius) and (not bestDist or pixelDist < bestDist) then
                    best, bestDist = zone, pixelDist
                end
            end
        end
    end

    return best
end

function OxTarget.disableTargeting(state)
    targetingDisabled = state == true
    ContextMenu.SetDisabled(targetingDisabled)
end

function OxTarget.isActive()
    return ContextMenu.IsOpen()
end

-- Cleanup: options and zones registered by a resource disappear when it stops ---

local function purgeOwnerFromList(list, resourceName)
    for i = #list, 1, -1 do
        if list[i]._owner == resourceName then
            table.remove(list, i)
        end
    end
end

AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then return end

    purgeOwnerFromList(globalPlayer, resourceName)
    purgeOwnerFromList(globalSelfPlayer, resourceName)
    purgeOwnerFromList(globalOtherPlayer, resourceName)
    purgeOwnerFromList(globalPed, resourceName)
    purgeOwnerFromList(globalVehicle, resourceName)
    purgeOwnerFromList(globalObject, resourceName)
    purgeOwnerFromList(globalOptions, resourceName)

    for _, list in pairs(models) do purgeOwnerFromList(list, resourceName) end
    for _, list in pairs(networkEntities) do purgeOwnerFromList(list, resourceName) end
    for _, list in pairs(localEntities) do purgeOwnerFromList(list, resourceName) end

    for id, zone in pairs(zones) do
        if zone._owner == resourceName then
            zones[id] = nil
        end
    end
end)

OxTargetMarkers = {
    draw = OxTarget.drawZoneMarkers,
    getAtScreen = OxTarget.getMarkerAtScreen,
}
