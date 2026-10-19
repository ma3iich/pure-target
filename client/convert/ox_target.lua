local exportHandler = Convert.exportHandler

-- ox_target exports. `addGlobalPlayer` targets OTHER players, like ox_target (its raycast ignores your own ped);
-- use `addGlobalSelfPlayer` for options on yourself.
local api = {
    addGlobalPlayer = OxTarget.addGlobalOtherPlayer,
    addGlobalSelfPlayer = OxTarget.addGlobalSelfPlayer,
    addGlobalOtherPlayer = OxTarget.addGlobalOtherPlayer,
    addGlobalPed = OxTarget.addGlobalPed,
    addGlobalVehicle = OxTarget.addGlobalVehicle,
    addGlobalObject = OxTarget.addGlobalObject,
    addGlobalOption = OxTarget.addGlobalOption,
    removeGlobalPlayer = function(names) OxTarget.removeGlobalOtherPlayer(names) OxTarget.removeGlobalPlayer(names) end,
    removeGlobalSelfPlayer = OxTarget.removeGlobalSelfPlayer,
    removeGlobalOtherPlayer = OxTarget.removeGlobalOtherPlayer,
    removeGlobalPed = OxTarget.removeGlobalPed,
    removeGlobalVehicle = OxTarget.removeGlobalVehicle,
    removeGlobalObject = OxTarget.removeGlobalObject,
    removeGlobalOption = OxTarget.removeGlobalOption,
    addModel = OxTarget.addModel,
    removeModel = OxTarget.removeModel,
    addEntity = OxTarget.addEntity,
    removeEntity = OxTarget.removeEntity,
    addLocalEntity = OxTarget.addLocalEntity,
    removeLocalEntity = OxTarget.removeLocalEntity,
    addSphereZone = OxTarget.addSphereZone,
    addBoxZone = OxTarget.addBoxZone,
    addPolyZone = OxTarget.addPolyZone,
    removeZone = OxTarget.removeZone,
    zoneExists = OxTarget.zoneExists,
    disableTargeting = OxTarget.disableTargeting,
    isActive = OxTarget.isActive,
}

for name, fn in pairs(api) do
    exports(name, fn)
    exportHandler('ox_target', name, fn)
end
