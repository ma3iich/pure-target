<div align="center">

[![English](https://img.shields.io/badge/Language-English-555)](README.md) [![Français](https://img.shields.io/badge/Langue-Fran%C3%A7ais-2ea44f)](README.fr.md)

# 🎯 Pure-Target

**Un menu clic droit standalone pour FiveM, qui remplace directement `ox_target`, `qtarget` et `qb-target`.**

Maintiens <kbd>Alt gauche</kbd>, fais un clic droit sur n'importe quoi dans le monde, et choisis une action.

![FiveM](https://img.shields.io/badge/FiveM-resource-orange)
![Lua](https://img.shields.io/badge/Lua-5.4-blue)
![Standalone](https://img.shields.io/badge/framework-standalone-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)
[![Downloads](https://img.shields.io/github/downloads/stefanlesuisse/pure-target/total?label=Downloads&color=2ea44f)](https://github.com/stefanlesuisse/pure-target/releases)

*Fork d'[Off-Target](https://www.youtube.com/watch?v=peS7m275vEY) par OffSey.*

<img src="docs/preview.png" alt="Menu Pure-Target" width="700">

</div>

---

## Fonctionnalités

- **Menu clic droit** à la place du classique « œil » : on maintient la touche, un curseur apparaît, on fait un
  clic droit sur ce qu'on veut.
- **Remplace directement** `ox_target`, `qtarget` et `qb-target` : tes scripts actuels continuent de marcher,
  rien à modifier.
- **Standalone** : aucun framework, pas d'ox_lib, pas de base de données. QBox / QBCore / ESX sont détectés
  automatiquement pour les filtres de métier et d'objets.
- **Ciblage précis** : sélectionne exactement l'objet sous le curseur, même les props de la map qui n'ont pas
  leur propre collision (distributeurs muraux, mobilier encastré...).
- **Le menu reste ouvert** tant que la touche est maintenue : on ouvre plusieurs portes à la suite, les textes
  se mettent à jour en direct.
- **Options véhicule intégrées** (désactivables) : ouvrir / fermer la porte, le capot ou le coffre visé ;
  baisser / remonter les fenêtres depuis l'intérieur (synchronisé pour tous les joueurs par le serveur,
  anti-spam, place vérifiée).
- **Interface soignée** : thème sombre au trait fin, ne sort jamais de l'écran, longues listes en colonnes,
  sous-menus, cases à cocher, lignes d'info, bulles d'aide.
- **13 langues** pour les options intégrées (EN, FR, DE, ES, IT, PT, NL, PL, TR, RU, ZH, JA, KO), facile
  d'en ajouter.
- **Léger** : aucune boucle ne tourne quand le menu est fermé ; le ciblage n'est calculé qu'au clic droit.
- **Sa propre API** pour créer tes menus (options, cases à cocher, sous-menus, séparateurs, lignes d'info).

## Comment ça marche

1. Maintiens la **touche du menu** (par défaut <kbd>Alt gauche</kbd>) : le curseur apparaît.
2. Fais un **clic droit** dans le monde.
3. Un rayon part du curseur et trouve l'entité / le modèle / la position en dessous.
4. Toutes les options enregistrées (ox_target, qtarget, qb-target et l'API Pure-Target) sont vérifiées.
5. Les options qui correspondent sont réunies dans un seul menu.

---

## Installation

1. Télécharge la [dernière version](../../releases) (ou clone ce dépôt).
2. Mets le dossier dans tes `resources` et **nomme-le `pure-target`**.
3. Dans `server.cfg`, démarre-le **avant** les scripts qui utilisent un système de ciblage :

```cfg
ensure pure-target
```

4. **Retire ou arrête** `ox_target`, `qtarget` et `qb-target` : pure-target les remplace
   (il déclare `provide 'ox_target'`, `provide 'qtarget'` et `provide 'qb-target'`).

L'interface est déjà compilée (`web/build`) : rien à compiler.

### Prérequis

- Un artefact de serveur FiveM récent (Lua 5.4, `cerulean`). OneSync est conseillé pour la synchro des fenêtres.
- Rien d'autre. En option : `ox_inventory`, `qbx_core`, `qb-core` ou `es_extended` pour les filtres `items` / `groups`.

---

## Configuration

Tout se trouve dans [`shared/config.lua`](shared/config.lua) :

| Réglage | Par défaut | Description |
| --- | --- | --- |
| `MenuKey` | `'LMENU'` | Touche à maintenir pour afficher le curseur. Les joueurs peuvent la changer dans *Paramètres → Raccourcis clavier → FiveM*. |
| `Locale` | `'en'` | Langue des options intégrées : `en`, `fr`, `de`, `es`, `it`, `pt`, `nl`, `pl`, `tr`, `ru`, `zh`, `ja`, `ko` (ajoute la tienne dans `shared/locales.lua`). |
| `RaycastDistance` | `300.0` | Distance maximale du rayon. |
| `DefaultDistance` | `7.0` | Distance des options qui n'ont pas de champ `distance` (valeur par défaut d'ox_target). |
| `MarkerClickRadius` | `18` | Rayon de clic (en pixels) des repères de zone. |
| `MarkerDrawDistance` | `7.0` | Distance maximale d'affichage des repères de zone. |
| `Framework` | `'auto'` | `'auto'`, `'qbx'`, `'qb'`, `'esx'` ou `'none'`. |
| `HasGroup` / `GetItemCount` | `nil` | Tes propres fonctions pour les autres frameworks. |
| `CanOpen` | fonction | Renvoie `false` pour bloquer le menu (mort, menotté...). |
| `IgnoreVehicleModels` | `{}` | Modèles de véhicules traités comme de simples objets (ex. fauteuils roulants). |
| `VehicleDoors` | `true` | Options intégrées portes / capot / coffre. |
| `VehicleWindows` | `true` | Options intégrées des fenêtres. |

Exemple, bloquer le menu quand le joueur est mort :

```lua
Config.CanOpen = function()
    return not IsPauseMenuActive() and not IsEntityDead(PlayerPedId())
end
```

---

## Utilisation

### Avec ox_target (code inchangé)

```lua
exports.ox_target:addModel('prop_atm_01', {
    {
        name = 'atm:use',
        label = 'Utiliser le distributeur',
        icon = 'fa-solid fa-credit-card',
        distance = 2.0,
        onSelect = function(data)
            print('Distributeur cliqué', data.entity)
        end,
    },
})
```

### Avec l'API Pure-Target

```lua
local ContextMenu = exports['pure-target']

ContextMenu:Register(function(entity, entityType, worldPos, hit)
    if not hit or entity ~= PlayerPedId() then return end

    local id = ContextMenu:AddItem(0, 'Lever les mains', 'fa-solid fa-hand')
    ContextMenu:OnActivate(id, function()
        TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_HANDS_UP', 0, true)
    end)
end)
```

D'autres exemples dans [`examples/`](examples/) (une ressource d'exemple prête à démarrer) et toutes les
fonctions dans [`exports.md`](exports.md) (en anglais).

### Ajouts de Pure-Target aux options ox_target

- `group = 'Police'` : les options d'un même groupe sont rangées dans un sous-menu (`groupIcon`, `groupColor`).
- `description = '...'` : bulle d'aide.
- `closeOnClick = true` : ferme le menu après cette option (par défaut : il reste ouvert tant que la touche
  est maintenue).
- `addGlobalSelfPlayer` / `addGlobalOtherPlayer` : options sur soi-même / sur les autres joueurs.

---

## Différences avec ox_target

- Pas d'« œil » ni de détection au survol : les options sont calculées **une fois par clic droit**, c'est
  pour ça que la ressource ne coûte rien quand le menu est fermé.
- Le menu reste ouvert tant que la touche est maintenue (voir `closeOnClick`).
- Les menus imbriqués (`openMenu` / `menuName`) s'affichent comme des sous-menus.
- Champs d'option pris en charge : voir [`exports.md`](exports.md#option-schema).

## Sécurité

`groups`, `items`, `distance` et `canInteract` décident seulement de ce qui est **affiché**. Un tricheur peut
déclencher n'importe quel événement serveur avec n'importe quels arguments : tes scripts serveur doivent
toujours vérifier eux-mêmes le métier, les objets, la distance, etc. L'option des fenêtres intégrée est
vérifiée par le serveur (joueur assis dans ce véhicule, à la bonne place, limite de fréquence).

---

## Compiler l'interface (seulement si tu la modifies)

```bash
cd web
npm ci
npm run build
```

| Commande | Description |
| --- | --- |
| `npm run dev` | Aperçu dans le navigateur (clic droit n'importe où pour ouvrir un menu de démo). |
| `npm run build` | Compilation finale dans `web/build`. |
| `npm run game` | Recompile à chaque modification (`vite build --watch`). |

---

## Structure du projet

```
pure-target/
├─ fxmanifest.lua
├─ shared/
│  ├─ config.lua            # réglages
│  └─ locales.lua           # textes des options intégrées
├─ client/
│  ├─ bridge.lua            # détection du framework / de l'inventaire (groups, items)
│  ├─ core/                 # cœur du menu, touche, rayon
│  ├─ convert/              # couches ox_target, qtarget et qb-target
│  └─ modules/              # portes et fenêtres des véhicules
├─ server/
│  └─ vehicle_windows.lua   # synchro des fenêtres (state bag), vérifications serveur
├─ examples/                # ressource d'exemple
└─ web/                     # interface React (Vite) — build/ est servi
```

---

## Crédits

- **[OffSey](https://www.youtube.com/watch?v=peS7m275vEY)** — Off-Target d'origine, dont Pure-Target est un fork.
- **[Kiminaze — ContextMenu](https://github.com/Kiminaze/ContextMenu)** — le menu clic droit d'origine, dont
  cette ressource suit le principe d'exports par identifiant.
- **[ox_target](https://github.com/overextended/ox_target)** (Overextended) et
  **[qtarget](https://github.com/overextended/qtarget)** — les API reproduites par les couches de compatibilité.
- Icônes : [Tabler Icons](https://tabler.io/icons) et [Font Awesome](https://fontawesome.com) (gratuites).

## Licence

[MIT](LICENSE) — libre d'utiliser, modifier et partager, en gardant la mention de copyright. Sans garantie.
