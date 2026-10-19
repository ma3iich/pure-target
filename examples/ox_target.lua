exports.ox_target:addGlobalVehicle({
    {
        name = 'flip_vehicle',
        label = 'Flip Vehicle',
        icon = 'fa-solid fa-rotate',
        distance = 3.0,
        onSelect = function(data)
            SetVehicleOnGroundProperly(data.entity)
        end,
    },
})

exports.ox_target:addGlobalOtherPlayer({
    {
        name = 'wave_player',
        label = 'Wave',
        icon = 'fa-solid fa-hand',
        distance = 2.5,
        onSelect = function()
            TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_CHEERING', 0, true)
        end,
    },
})

exports.ox_target:addModel({ 'prop_atm_01', 'prop_atm_02', 'prop_atm_03' }, {
    {
        name = 'use_atm',
        label = 'Use ATM',
        icon = 'fa-solid fa-money-bill',
        distance = 1.5,
        onSelect = function()
            print('open atm ui')
        end,
    },
})

exports.ox_target:addSphereZone({
    coords = vector3(195.0, -933.0, 30.0),
    radius = 2.0,
    marker = true,
    markerRadius = 20,
    markerColor = { 99, 102, 241 },
    distance = 10.0,
    options = {
        {
            name = 'shop_zone',
            label = 'Open Shop',
            icon = 'fa-solid fa-store',
            onSelect = function()
                print('open shop')
            end,
        },
    },
})

exports.ox_target:addBoxZone({
    coords = vector3(-1037.0, -2738.0, 20.0),
    size = vector3(3.0, 3.0, 2.0),
    options = {
        {
            name = 'box_action',
            label = 'Box Action',
            icon = 'fa-solid fa-cube',
            serverEvent = 'pure-target:exampleEvent',
        },
    },
})
