-- Example resource: copy this folder into your resources (e.g. resources/pure-target-examples)
-- and add `ensure pure-target-examples` AFTER `ensure pure-target` in server.cfg.
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

dependency 'pure-target'

client_scripts {
    'menu_api.lua',
    'ox_target.lua',
    'qtarget.lua',
}
