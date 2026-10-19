exports.qtarget:Vehicle({
    options = {
        {
            label = 'Flip Vehicle',
            icon = 'fa-solid fa-rotate',
            action = function(entity)
                SetVehicleOnGroundProperly(entity)
            end,
        },
    },
    distance = 3.0,
})

exports.qtarget:Player({
    type = 'other',
    options = {
        {
            label = 'Wave',
            icon = 'fa-solid fa-hand',
            action = function()
                TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_CHEERING', 0, true)
            end,
        },
    },
    distance = 2.5,
})

exports.qtarget:AddTargetModel({ 'prop_atm_01', 'prop_atm_02', 'prop_atm_03' }, {
    options = {
        {
            label = 'Use ATM',
            icon = 'fa-solid fa-money-bill',
            action = function()
                print('open atm ui')
            end,
        },
    },
    distance = 1.5,
})

exports.qtarget:AddCircleZone('shop_zone', vector3(195.0, -933.0, 30.0), 2.0, {
    name = 'shop_zone',
}, {
    options = {
        {
            label = 'Open Shop',
            icon = 'fa-solid fa-store',
            event = 'pure-target:exampleEvent',
            type = 'server',
        },
    },
    distance = 2.5,
})

exports.qtarget:AddBoxZone('box_zone', vector3(-1037.0, -2738.0, 20.0), 3.0, 3.0, {
    name = 'box_zone',
    heading = 0.0,
    minZ = 19.0,
    maxZ = 22.0,
}, {
    options = {
        {
            label = 'Box Action',
            icon = 'fa-solid fa-cube',
            action = function()
                print('box action')
            end,
        },
    },
    distance = 2.5,
})
