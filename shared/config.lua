Config = {}

-- Key held to show the cursor (FiveM key name). Players can rebind it in
-- Settings > Key Bindings > FiveM. Common names: LMENU (Left Alt), RMENU, LCONTROL, B, F1...
Config.MenuKey = 'LMENU'

-- Language of the built-in options and of the key binding (see shared/locales.lua):
-- 'en', 'fr', 'de', 'es', 'it', 'pt', 'nl', 'pl', 'tr', 'ru', 'zh' (Simplified Chinese), 'ja', 'ko'.
Config.Locale = 'en'

-- Max distance of the screen raycast (metres).
Config.RaycastDistance = 300.0

-- ox_target options without a `distance` field are shown up to this distance (ox_target default: 7).
Config.DefaultDistance = 7.0

-- Zone markers (ox_target zones): click radius in pixels, and max distance they are drawn at.
Config.MarkerClickRadius = 18
Config.MarkerDrawDistance = 7.0

-- Framework used for the `groups` (jobs / gangs) and `items` filters of ox_target options.
--   'auto' : detected at runtime (qbx_core, qb-core, es_extended)
--   'qbx' | 'qb' | 'esx' : forced
--   'none' : standalone, no framework
-- Options that use `groups` are HIDDEN when no framework is found (safer than showing them to everyone),
-- unless you provide Config.HasGroup below.
Config.Framework = 'auto'

-- Optional overrides for other frameworks (ox_core, ND_Core, your own...). Leave nil to use the bridge.
-- Config.HasGroup = function(filter) return true end          -- filter: 'police' | { 'police', 'ems' } | { police = 2 }
-- Config.GetItemCount = function(itemName) return 0 end
Config.HasGroup = nil
Config.GetItemCount = nil

-- Called before the menu opens: return false to block it (dead, handcuffed, in a cutscene...).
Config.CanOpen = function()
    return not IsPauseMenuActive()
end

-- Vehicle models handled as plain objects by the menu (no door / window options), e.g. wheelchairs.
Config.IgnoreVehicleModels = {
    -- 'my_wheelchair',
}

-- Built-in vehicle options (client/modules/vehicle_doors.lua). Set to false to disable them.
Config.VehicleDoors = true   -- open / close the door, hood or trunk you click on
Config.VehicleWindows = true -- roll windows up / down from inside the vehicle (synced by the server)
