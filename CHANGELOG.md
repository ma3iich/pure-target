# Changelog

## 1.2.1

### Added
- Update check: 10 s after the resource starts, the server console says when a newer version is available on
  GitHub. Nothing is downloaded. `Config.CheckUpdates = false` turns it off.

### Changed
- Clearer code comments. No change in behaviour.

## 1.2.0

### Fixed
- qb-target `SpawnPed` (+ `RemoveSpawnedPed`, `DeletePeds`, `GetPeds`): peds spawned through qb-target did not
  appear (qb-taxijob). They are deleted when the resource that spawned them stops.
- `RemoveZone(name)` now also removes the options added with `AddEntityZone(name, ...)` (qb-hotdogjob, qb-drugs,
  qb-vehiclesales: the selling option stayed on the previous ped).

### Documentation
- README (EN / FR): `setr UseTarget true` is required for the QBCore scripts to use a target system.

## 1.1.0

### Fixed
- Icons showing as white squares the first time the menu is opened after joining: the Font Awesome and Tabler
  icon fonts are now included in the resource (`web/build/assets/vendor`, with their licenses) and loaded as soon
  as the player joins, instead of being downloaded from a CDN on the first right-click.

## 1.0.0

First release of Pure-Target, a fork of Off-Target 2.0.0 by OffSey. Changes compared to Off-Target 2.0.0:

### Added
- Standalone framework bridge: `groups` (jobs / gangs) and `items` filters now work with qbx_core, qb-core,
  es_extended and ox_inventory, detected automatically (`Config.Framework`, `Config.HasGroup`, `Config.GetItemCount`).
- ox_target `bones`, `offset` / `absoluteOffset` / `offsetSize`, nested menus (`openMenu` / `menuName`),
  `zoneExists`, `isActive`, box zone `rotation`, removal of zones by name.
- qb-target exports: `AddEntityZone`, `AddGlobalPed/Vehicle/Object/Player` (+ `RemoveGlobal*`), `AllowTargeting`,
  `IsTargetActive`; `gang` and `citizenid` filters.
- Menu stays open while the key is held and refreshes after each click; `CloseOnClick` / `closeOnClick`.
- Precise targeting of map props without their own collision (wall ATMs, built-in furniture...).
- Built-in vehicle options: aimed door / hood / trunk, windows synced by the server (`Config.VehicleDoors`,
  `Config.VehicleWindows`), texts in 13 languages (en, fr, de, es, it, pt, nl, pl, tr, ru, zh, ja, ko).
- New exports: `Unregister`, `Close`, `IsOpen`, `SetDisabled`. `Config.CanOpen`, `Config.IgnoreVehicleModels`.
- Thin-line UI theme (Tabler icons, Font Awesome names still accepted), menu never off screen, long lists in
  columns, description tooltips, one action at a time.

### Changed
- Option actions now receive the same data as ox_target (copy of the option + entity, coords, distance, zone);
  `serverEvent` receives the network id of the entity; `export` options are called like ox_target.
- `canInteract` returning `nil` now hides the option (same as ox_target).
- Calling `remove*` without names only removes the options of the calling resource.
- Game mouse / weapon-wheel controls are disabled while the menu is open (no drive-by aiming in vehicles).
- Zone markers: only nearby zones are tested each frame.
- No dependency on ox_lib anymore.

### Removed
- Paging (`Config.ItemsPerPage`): the whole menu is always shown.
