local ContextMenu = exports['pure-target']

ContextMenu:Register(function(entity, entityType, worldPos, hit)
    if not hit then return end

    local ped = PlayerPedId()
    if entity ~= ped then return end

    ContextMenu:SetHeader('Me', 'fa-solid fa-user')

    local handsUp = ContextMenu:AddItem(0, 'Hands Up', 'fa-solid fa-hands', { color = { 99, 102, 241 } })
    ContextMenu:OnActivate(handsUp, function()
        TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_HANDS_UP', 0, true)
    end)

    local stopAnim = ContextMenu:AddItem(0, 'Stop Animation', 'fa-solid fa-ban', { color = { 239, 68, 68 } }, 'Stop current animation')
    ContextMenu:OnActivate(stopAnim, function()
        ClearPedTasks(PlayerPedId())
    end)

    ContextMenu:AddSeparator(0)

    local drunk = ContextMenu:AddCheckbox(0, 'Drunk Walk', false, 'fa-solid fa-shoe-prints')
    ContextMenu:OnValueChanged(drunk, function(checked)
        if checked then
            SetPedMovementClipset(PlayerPedId(), 'move_m@drunk@verydrunk', 1.0)
        else
            ResetPedMovementClipset(PlayerPedId(), 0.0)
        end
    end)

    local emotes = ContextMenu:AddSubmenu(0, 'Emotes', 'fa-solid fa-face-smile', { color = { 234, 179, 8 } }, 'EMOTES')

    local salute = ContextMenu:AddItem(emotes, 'Salute', 'fa-solid fa-hand')
    ContextMenu:OnActivate(salute, function()
        TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_GUARD_STAND', 0, true)
    end)

    local smoke = ContextMenu:AddItem(emotes, 'Smoke', 'fa-solid fa-smoking')
    ContextMenu:OnActivate(smoke, function()
        TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_SMOKING', 0, true)
    end)

    ContextMenu:AddInfo(0, 'Health', tostring(GetEntityHealth(ped) - 100), 'fa-solid fa-heart-pulse')
end)

ContextMenu:Register(function(entity, entityType, worldPos, hit)
    if not hit or entity == 0 then return end
    if entityType ~= 2 then return end

    ContextMenu:SetHeader('Vehicle', 'fa-solid fa-car')

    ContextMenu:AddInfo(0, 'Plate', GetVehicleNumberPlateText(entity), 'fa-solid fa-id-card')

    local engine = ContextMenu:AddItem(0, 'Toggle Engine', 'fa-solid fa-power-off', { color = { 99, 102, 241 } })
    ContextMenu:OnActivate(engine, function(ent)
        SetVehicleEngineOn(ent, not GetIsVehicleEngineRunning(ent), false, true)
    end)

    local lock = ContextMenu:AddItem(0, 'Lock / Unlock', 'fa-solid fa-lock', { color = { 234, 179, 8 } })
    ContextMenu:OnActivate(lock, function(ent)
        SetVehicleDoorsLocked(ent, GetVehicleDoorLockStatus(ent) == 2 and 1 or 2)
    end)

    ContextMenu:AddSeparator(0)

    local fix = ContextMenu:AddItem(0, 'Clean & Repair', 'fa-solid fa-wrench', { color = { 16, 185, 129 } })
    ContextMenu:OnActivate(fix, function(ent)
        SetVehicleFixed(ent)
        SetVehicleDirtLevel(ent, 0.0)
    end)
end)

ContextMenu:Register(function(entity, entityType, worldPos, hit)
    if not hit then return end
    if entity and entity ~= 0 then return end

    ContextMenu:SetHeader('World', 'fa-solid fa-location-dot')

    ContextMenu:AddInfo(0, 'Position',
        ('%.1f, %.1f, %.1f'):format(worldPos.x, worldPos.y, worldPos.z),
        'fa-solid fa-map-pin')

    ContextMenu:AddSeparator(0)

    local tp = ContextMenu:AddItem(0, 'Teleport here', 'fa-solid fa-person-walking-arrow-right', { color = { 16, 185, 129 } })
    ContextMenu:OnActivate(tp, function(_, coords)
        local c = coords or worldPos
        SetPedCoordsKeepVehicle(PlayerPedId(), c.x, c.y, c.z + 1.0)
    end)

    local wp = ContextMenu:AddItem(0, 'Set Waypoint', 'fa-solid fa-flag', { color = { 99, 102, 241 } })
    ContextMenu:OnActivate(wp, function(_, coords)
        local c = coords or worldPos
        SetNewWaypoint(c.x, c.y)
    end)
end)
