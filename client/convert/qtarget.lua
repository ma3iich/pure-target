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
register('AddEntityZone', function(name, entity, options, targetoptions)
    addEntities(entity, convert(targetoptions))
    return name
end)

register('RemoveZone', function(id)
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

-- State -----------------------------------------------------------------------

register('AllowTargeting', function(state) OxTarget.disableTargeting(state == false) end)
register('IsTargetActive', function() return ContextMenu.IsOpen() end)
