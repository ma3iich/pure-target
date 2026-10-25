-- qtarget / qb-target compatibility: same exports, converted to ox_target options (Convert.qtargetOptions).
local exportHandler = Convert.exportHandler
local convert = Convert.qtargetOptions

local function register(name, fn)
    exports(name, fn)
    exportHandler('qtarget', name, fn)
    -- `provide 'qb-target'` does not redirect export calls: exports['qb-target']:... are answered here too.
    exportHandler('qb-target', name, fn)
end

local function addEntities(entities, options)
    if type(entities) ~= 'table' then entities = { entities } end
    for i = 1, #entities do
        local entity = entities[i]
        if NetworkGetEntityIsNetworked(entity) then
            OxTarget.addEntity(NetworkGetNetworkIdFromEntity(entity), options)
        else
            OxTarget.addLocalEntity(entity, options)
        end
    end
end

local function removeEntities(entities, labels)
    if type(entities) ~= 'table' then entities = { entities } end
    for i = 1, #entities do
        local entity = entities[i]
        if NetworkGetEntityIsNetworked(entity) then
            OxTarget.removeEntity(NetworkGetNetworkIdFromEntity(entity), labels)
        else
            OxTarget.removeLocalEntity(entity, labels)
        end
    end
end

-- Zones ----------------------------------------------------------------------

register('AddBoxZone', function(name, center, length, width, options, targetoptions)
    options = options or {}
    -- PolyZone without minZ / maxZ has no height limit.
    local minZ, maxZ = options.minZ or -100.0, options.maxZ or 800.0
    return OxTarget.addBoxZone({
        name = name,
        coords = vec3(center.x, center.y, (minZ + maxZ) / 2),
        size = vec3(width, length, math.abs(maxZ - minZ)),
        markerCoords = center,
        rotation = options.heading,
        options = convert(targetoptions),
    })
end)

register('AddPolyZone', function(name, points, options, targetoptions)
    options = options or {}
    local minZ, maxZ = options.minZ or -100.0, options.maxZ or 800.0
    local newPoints, sx, sy = {}, 0.0, 0.0
    for i = 1, #points do
        newPoints[i] = vec3(points[i].x, points[i].y, (minZ + maxZ) / 2)
        sx, sy = sx + points[i].x, sy + points[i].y
    end
    -- Marker at the centre of the polygon, 1 m above its floor (only when the floor is known).
    local markerCoords = options.minZ and #points > 0 and vec3(sx / #points, sy / #points, options.minZ + 1.0) or nil
    return OxTarget.addPolyZone({
        name = name,
        points = newPoints,
        minZ = minZ,
        maxZ = maxZ,
        markerCoords = markerCoords,
        drawSprite = markerCoords ~= nil,
        options = convert(targetoptions),
    })
end)

register('AddCircleZone', function(name, center, radius, options, targetoptions)
    return OxTarget.addSphereZone({
        name = name,
        coords = center,
        radius = radius,
        options = convert(targetoptions),
    })
end)

-- qb-target: zone that follows an entity -> options on that entity.
-- The name is kept so that RemoveZone(name) also removes these options (qb-hotdogjob, qb-drugs...).
local entityZones = {}

local function optionNames(options)
    local names = {}
    for i = 1, #options do names[#names + 1] = options[i].name end
    return names
end

register('AddEntityZone', function(name, entity, options, targetoptions)
    local converted = convert(targetoptions)
    addEntities(entity, converted)
    entityZones[name] = { entity = entity, names = optionNames(converted) }
    return name
end)

register('RemoveZone', function(id)
    local entityZone = entityZones[id]
    if entityZone then
        entityZones[id] = nil
        removeEntities(entityZone.entity, entityZone.names)
    end
    OxTarget.removeZone(id)
end)

-- Bones, entities, models -----------------------------------------------------

register('AddTargetBone', function(bones, options)
    if type(bones) ~= 'table' then bones = { bones } end
    options = convert(options)
    for _, v in pairs(options) do
        v.bones = bones
    end
    OxTarget.addGlobalVehicle(options)
end)

register('AddTargetEntity', function(entities, options)
    addEntities(entities, convert(options))
end)

register('RemoveTargetEntity', removeEntities)

register('AddTargetModel', function(models, options)
    OxTarget.addModel(models, convert(options))
end)

register('RemoveTargetModel', function(models, labels)
    OxTarget.removeModel(models, labels)
end)

-- Globals (qtarget names) -----------------------------------------------------

register('Ped', function(options) OxTarget.addGlobalPed(convert(options)) end)
register('RemovePed', function(labels) OxTarget.removeGlobalPed(labels) end)
register('Vehicle', function(options) OxTarget.addGlobalVehicle(convert(options)) end)
register('RemoveVehicle', function(labels) OxTarget.removeGlobalVehicle(labels) end)
register('Object', function(options) OxTarget.addGlobalObject(convert(options)) end)
register('RemoveObject', function(labels) OxTarget.removeGlobalObject(labels) end)
register('Globals', function(options) OxTarget.addGlobalOption(convert(options)) end)
register('RemoveGlobals', function(labels) OxTarget.removeGlobalOption(labels) end)

local function addPlayer(options)
    local playerType = options and options.type
    if playerType == 'self' then
        OxTarget.addGlobalSelfPlayer(convert(options))
    elseif playerType == 'other' then
        OxTarget.addGlobalOtherPlayer(convert(options))
    else
        OxTarget.addGlobalPlayer(convert(options))
    end
end

local function removePlayer(labels)
    OxTarget.removeGlobalPlayer(labels)
    OxTarget.removeGlobalOtherPlayer(labels)
    OxTarget.removeGlobalSelfPlayer(labels)
end

register('Player', addPlayer)
register('RemovePlayer', removePlayer)

-- Globals (qb-target names) ---------------------------------------------------

register('AddGlobalPed', function(options) OxTarget.addGlobalPed(convert(options)) end)
register('RemoveGlobalPed', function(labels) OxTarget.removeGlobalPed(labels) end)
register('AddGlobalVehicle', function(options) OxTarget.addGlobalVehicle(convert(options)) end)
register('RemoveGlobalVehicle', function(labels) OxTarget.removeGlobalVehicle(labels) end)
register('AddGlobalObject', function(options) OxTarget.addGlobalObject(convert(options)) end)
register('RemoveGlobalObject', function(labels) OxTarget.removeGlobalObject(labels) end)
register('AddGlobalPlayer', function(options) OxTarget.addGlobalOtherPlayer(convert(options)) end)
register('RemoveGlobalPlayer', removePlayer)

-- Peds (qb-target SpawnPed) -----------------------------------------------------
-- Local ped with its target options (qb-taxijob...). Spawned right away, deleted when the resource that
-- spawned it stops.

local spawnedPeds = {}

local function loadAsset(request, isLoaded, asset)
    request(asset)
    local timeout = GetGameTimer() + 10000
    while not isLoaded(asset) do
        if GetGameTimer() > timeout then return false end
        Wait(0)
    end
    return true
end

local function spawnPed(data, owner)
    local model = type(data.model) == 'string' and joaat(data.model) or data.model
    if not model or not IsModelInCdimage(model) or not loadAsset(RequestModel, HasModelLoaded, model) then
        print(('^3[pure-target] SpawnPed: model %s not found^0'):format(tostring(data.model)))
        return
    end

    local coords = data.coords
    local z = data.minusOne and coords.z - 1.0 or coords.z
    local ped = CreatePed(0, model, coords.x, coords.y, z, coords.w or 0.0, data.networked or false, true)
    SetModelAsNoLongerNeeded(model)

    if data.freeze then FreezeEntityPosition(ped, true) end
    if data.invincible then SetEntityInvincible(ped, true) end
    if data.blockevents then SetBlockingOfNonTemporaryEvents(ped, true) end

    if data.animDict and data.anim and DoesAnimDictExist(data.animDict)
        and loadAsset(RequestAnimDict, HasAnimDictLoaded, data.animDict) then
        TaskPlayAnim(ped, data.animDict, data.anim, 8.0, 0, -1, data.flag or 1, 0, false, false, false)
    end

    if data.scenario then
        SetPedCanPlayAmbientAnims(ped, true)
        TaskStartScenarioInPlace(ped, data.scenario, 0, true)
    end

    local relations = data.pedrelations
    if relations and type(relations.groupname) == 'string' then
        local group = joaat(relations.groupname)
        if not DoesRelationshipGroupExist(group) then AddRelationshipGroup(relations.groupname) end
        SetPedRelationshipGroupHash(ped, group)
        if relations.toplayer then SetRelationshipBetweenGroups(relations.toplayer, group, joaat('PLAYER')) end
        if relations.toowngroup then SetRelationshipBetweenGroups(relations.toowngroup, group, group) end
    end

    if data.weapon then
        local weapon = type(data.weapon.name) == 'string' and joaat(data.weapon.name) or data.weapon.name
        if weapon and IsWeaponValid(weapon) then
            SetCanPedEquipWeapon(ped, weapon, true)
            GiveWeaponToPed(ped, weapon, data.weapon.ammo or 0, data.weapon.hidden or false, true)
            SetPedCurrentWeaponVisible(ped, not data.weapon.hidden, true)
        end
    end

    local names = {}
    if data.target then
        local options = convert(data.target)
        names = optionNames(options)
        if data.target.useModel then
            OxTarget.addModel(model, options)
        else
            OxTarget.addLocalEntity(ped, options)
        end
    end

    data.currentpednumber = ped
    spawnedPeds[#spawnedPeds + 1] = { ped = ped, data = data, owner = owner, names = names }

    if data.action then data.action(data) end
    return ped
end

local function deletePeds(match)
    for i = #spawnedPeds, 1, -1 do
        local entry = spawnedPeds[i]
        if match(entry) then
            table.remove(spawnedPeds, i)
            if not entry.data.target or not entry.data.target.useModel then
                OxTarget.removeLocalEntity(entry.ped, entry.names)
            end
            if DoesEntityExist(entry.ped) then DeleteEntity(entry.ped) end
            entry.data.currentpednumber = 0
        end
    end
end

-- data: one ped, or a list of peds.
register('SpawnPed', function(data)
    if type(data) ~= 'table' then return end
    local owner = Convert.currentOwner()
    if data.model then return spawnPed(data, owner) end
    for _, ped in pairs(data) do
        if type(ped) == 'table' then spawnPed(ped, owner) end
    end
end)

-- peds: a ped handle, or a list of handles.
register('RemoveSpawnedPed', function(peds)
    local lookup = {}
    for _, ped in pairs(type(peds) == 'table' and peds or { peds }) do lookup[ped] = true end
    deletePeds(function(entry) return lookup[entry.ped] end)
end)

register('DeletePeds', function()
    deletePeds(function() return true end)
end)

register('GetPeds', function()
    local list = {}
    for i = 1, #spawnedPeds do list[i] = spawnedPeds[i].data end
    return list
end)

AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        deletePeds(function() return true end)
    else
        deletePeds(function(entry) return entry.owner == resourceName end)
    end
end)

-- State -----------------------------------------------------------------------

register('AllowTargeting', function(state) OxTarget.disableTargeting(state == false) end)
register('IsTargetActive', function() return ContextMenu.IsOpen() end)
