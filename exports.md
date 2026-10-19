# Pure-Target — Exports reference

Every export exposed by this resource, in one place.

- [Menu exports](#menu-exports)
- [ox_target compatibility](#ox_target-compatibility)
- [qtarget / qb-target compatibility](#qtarget--qb-target-compatibility)
- [Option schema](#option-schema)

The resource folder must be named `pure-target`:

```lua
local ContextMenu = exports['pure-target']
```

---

## Menu exports

Build your own entries. Inside a `Register` callback you add entries (each returns a numeric **id**), then
attach behaviour to those ids. The callback runs on every right-click, so the menu always reflects the
current state of the game.

| Export | Returns | Purpose |
| --- | --- | --- |
| `Register(fn)` | uid | Register a menu-building callback. |
| `Unregister(uid)` | boolean | Remove a callback registered with `Register`. |
| `SetHeader(name, icon)` | — | Title row of the current build (hidden by the default theme). |
| `AddItem(parent, name, icon, style, description)` | id | Clickable entry. |
| `AddCheckbox(parent, name, checked, icon, style, description)` | id | Toggle entry. |
| `AddSubmenu(parent, name, icon, style, headerName, description)` | id | Nested submenu. |
| `AddSeparator(parent)` | id | Horizontal divider. |
| `AddInfo(parent, name, value, icon, style, description)` | id | Read-only row; clicking it copies `value`. |
| `OnActivate(id, fn)` | — | Click handler: `fn(entity, worldPos)`. |
| `OnValueChanged(id, fn)` | — | Checkbox handler: `fn(checked, entity, worldPos)`. |
| `CloseOnClick(id)` | — | This entry closes the menu when clicked (see below). |
| `KeepOpen(id)` | — | Kept for backwards compatibility, does nothing (every entry keeps the menu open). |
| `Toggle()` / `Close()` | — | Open / close the menu from code. |
| `IsOpen()` | boolean | Is the cursor mode active? |
| `SetDisabled(state)` | — | `true` blocks the menu entirely (cutscene, death screen...). |

`parent` is `0` for the root menu, or a submenu id returned by `AddSubmenu`.

### `Register(fn)`

```lua
ContextMenu:Register(function(entity, entityType, worldPos, hit)
    if not hit or entityType ~= 2 then return end -- vehicles only

    local id = ContextMenu:AddItem(0, 'Toggle engine', 'fa-solid fa-power-off')
    ContextMenu:OnActivate(id, function(ent)
        SetVehicleEngineOn(ent, not GetIsVehicleEngineRunning(ent), false, true)
    end)
end)
```

| Callback param | Type | Description |
| --- | --- | --- |
| `entity` | number | Entity under the cursor (`0` if none). |
| `entityType` | number | `0` world · `1` ped · `2` vehicle · `3` object. |
| `worldPos` | vector3 | World position under the cursor. |
| `hit` | boolean | `true` if the ray hit something. |

Adding no entries simply contributes nothing. A callback that throws is printed and removed, it never
breaks the other ones. Callbacks are removed automatically when their resource stops.

### Menu stays open

As long as the menu key is held, clicking an entry runs it and **keeps the menu open**: ~350 ms later the
menu is rebuilt at the same place, so labels are up to date ("Open the door" becomes "Close the door").
It closes when:

- the menu key is released;
- another NUI page takes the mouse (inventory, phone, ox_lib menu...);
- the game switches to another camera;
- the entry was marked with `CloseOnClick(id)` (ox_target: `closeOnClick = true` or `keepOpen = false`).
  Use it for actions that take the mouse without opening a NUI page, e.g. a placement gizmo.

### Style and icons

```lua
style = { color = { r, g, b } }   -- 0–255: colours the ICON of the entry
```

Icons: [Font Awesome 6](https://fontawesome.com/search) free classes (`'fa-solid fa-car'`) are shown as their
[Tabler](https://tabler.io/icons) equivalent to match the thin-line theme. You can also pass a Tabler class
directly (`'ti ti-car'`). Font Awesome icons without an equivalent are shown as is.

---

## ox_target compatibility

`provide 'ox_target'`: resources that depend on ox_target start normally, and every
`exports.ox_target:*` call is answered by pure-target.

| Export | Notes |
| --- | --- |
| `addGlobalPlayer(options)` / `removeGlobalPlayer(names)` | Other players (like ox_target, which never targets your own ped). |
| `addGlobalSelfPlayer` / `removeGlobalSelfPlayer` | **Extension**: options on yourself. |
| `addGlobalOtherPlayer` / `removeGlobalOtherPlayer` | **Extension**: same as `addGlobalPlayer`. |
| `addGlobalPed` / `removeGlobalPed` | NPC peds. |
| `addGlobalVehicle` / `removeGlobalVehicle` | All vehicles. |
| `addGlobalObject` / `removeGlobalObject` | All objects. |
| `addGlobalOption` / `removeGlobalOption` | Everywhere. |
| `addModel(models, options)` / `removeModel(models, names)` | Model name(s) or hash(es). |
| `addEntity(netIds, options)` / `removeEntity(netIds, names)` | Networked entities. |
| `addLocalEntity(entities, options)` / `removeLocalEntity(entities, names)` | Local entities. |
| `addSphereZone(params)` → id | `coords`, `radius`, `options`, `name`. |
| `addBoxZone(params)` → id | `coords`, `size`, `rotation` (degrees), `options`, `name`. |
| `addPolyZone(params)` → id | `points`, `thickness`, `minZ`/`maxZ`, `options`, `name`. |
| `removeZone(idOrName)` / `zoneExists(idOrName)` | |
| `disableTargeting(state)` | `true` disables the whole menu. |
| `isActive()` | Is the cursor mode active? |

Calling a `remove*` export **without names** only removes the options of the calling resource.

Zones show a small marker (dot) while the menu is open; right-clicking the marker opens the zone options.
Extra zone params: `drawSprite = false` (no marker), `markerColor = { r, g, b, a }`,
`markerRadius` (click radius in pixels), `markerDistance` (max draw distance).

---

## qtarget / qb-target compatibility

`provide 'qtarget'` and `provide 'qb-target'`; both `exports.qtarget:*` and `exports['qb-target']:*` work.

| Export | Notes |
| --- | --- |
| `AddBoxZone(name, center, length, width, options, targetoptions)` | `heading`, `minZ`, `maxZ` supported. |
| `AddPolyZone(name, points, options, targetoptions)` | |
| `AddCircleZone(name, center, radius, options, targetoptions)` | |
| `AddEntityZone(name, entity, options, targetoptions)` | Options on that entity. |
| `RemoveZone(name)` | |
| `AddTargetBone(bones, targetoptions)` | Vehicle bones. |
| `AddTargetEntity(entities, targetoptions)` / `RemoveTargetEntity(entities, labels)` | |
| `AddTargetModel(models, targetoptions)` / `RemoveTargetModel(models, labels)` | |
| `Ped` / `Vehicle` / `Object` / `Player` / `Globals` (+ `Remove*`) | qtarget names. `Player` accepts `type = 'self'` or `'other'`. |
| `AddGlobalPed` / `AddGlobalVehicle` / `AddGlobalObject` / `AddGlobalPlayer` (+ `RemoveGlobal*`) | qb-target names. |
| `AllowTargeting(state)` / `IsTargetActive()` | |

qtarget / qb-target option fields are converted: `action(entity)`, `event` + `type`
(`'client'`, `'server'`, `'command'`), `job` (→ `groups`), `gang`, `citizenid`, `item` / `required_item`.

---

## Option schema

Same fields as ox_target:

```lua
{
    name        = 'unique_id',          -- used by remove*
    label       = 'Shown text',
    icon        = 'fa-solid fa-gear',
    iconColor   = '#f59e0b',            -- or { r, g, b }
    description = 'Tooltip text',       -- extension
    distance    = 2.0,                  -- max distance player -> clicked point (default Config.DefaultDistance = 7)

    groups      = 'police',             -- or { 'police', 'ambulance' } or { police = 2 } (minimum grade)
    items       = 'lockpick',           -- or { 'lockpick', 'screwdriver' } or { lockpick = 2 }
    anyItem     = false,                -- true: one of the items is enough
    bones       = { 'door_dside_f' },   -- shown only near one of these bones
    offset      = vec3(0.5, 0.5, 0.5),  -- shown only near this point of the model (0..1, or metres
    absoluteOffset = false,             --   with absoluteOffset = true), within offsetSize (default 1 m)
    offsetSize  = 1.0,

    canInteract = function(entity, distance, coords, name, bone)
        return true                     -- false / nil / error hides the option
    end,

    -- pure-target extensions
    group       = 'Police',             -- options sharing a group are put in a submenu
    groupIcon   = 'fa-solid fa-shield-halved',
    groupColor  = '#3b82f6',
    closeOnClick = false,

    -- ox_target nested menus
    openMenu    = 'my_submenu',         -- this option becomes a submenu...
    menuName    = 'my_submenu',         -- ...holding the options with this menuName

    -- action: the first field present wins
    onSelect    = function(data) end,
    export      = 'method',             -- with resource = 'name' (default: the registering resource),
                                        -- or 'resource.method'
    event       = 'client:event',
    serverEvent = 'server:event',
    command     = 'somecommand',
}
```

### Action `data`

Like ox_target, the action receives a copy of the option plus:

```lua
{ entity = <handle>, coords = <vector3>, distance = <number>, zone = <zone id or nil>, ... }
```

For `serverEvent`, `entity` is the **network id** (0 if the entity is not networked). qtarget `action`
functions receive the entity handle, like qtarget.

> **Security:** `groups`, `items`, `canInteract` and `distance` only decide what is SHOWN. A cheater can trigger
> any server event directly: your server code must always check job, items, distance... itself.

### `groups` and `items` sources

| Framework | groups | items |
| --- | --- | --- |
| qbx_core | `HasGroup` (job + gang) | ox_inventory |
| qb-core | job + gang (grade.level) | ox_inventory, else PlayerData.items |
| es_extended | job (+ job2) | ox_inventory, else PlayerData.inventory |
| none | options with `groups` are **hidden** | ox_inventory if running |

Other frameworks: set `Config.HasGroup` / `Config.GetItemCount` in `shared/config.lua`.
