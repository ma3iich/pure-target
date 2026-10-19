fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'pure-target'
author 'Pure-Target contributors (fork of Off-Target by OffSey)'
description 'Standalone right-click context menu with drop-in ox_target / qtarget / qb-target compatibility'
version '1.0.0'

provide 'ox_target'
provide 'qtarget'
provide 'qb-target'

shared_scripts {
    'shared/config.lua',
    'shared/locales.lua',
}

client_scripts {
    'client/bridge.lua',
    'client/core/keys.lua',
    'client/core/contextmenu.lua',
    'client/convert/_utils.lua',
    'client/convert/target.lua',
    'client/convert/ox_target.lua',
    'client/convert/qtarget.lua',
    'client/modules/vehicle_doors.lua',
}

server_scripts {
    'server/vehicle_windows.lua',
}

ui_page 'web/build/index.html'

files {
    'web/build/index.html',
    'web/build/assets/*',
}
