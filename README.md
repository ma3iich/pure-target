<details name="langue">
<summary><picture><img src="https://img.shields.io/badge/Langue-Fran%C3%A7ais-2ea44f?style=for-the-badge&labelColor=0D0D0D" alt="Français"></picture></summary>

<div align="center">

<sub>🧩 <b>Suite Pure</b> &nbsp;·&nbsp; <b>Pure-Target</b> (menu clic droit) &nbsp;·&nbsp; <a href="https://github.com/ma3iich/pure_inventory">Pure Inventory</a> (inventaire) &nbsp;—&nbsp; chacun marche seul, et ils marchent ensemble</sub>


<img src="docs/banner.png" alt="Pure-Target — le menu clic droit pour FiveM" width="100%">

<br>

**Un menu clic droit standalone pour FiveM, qui remplace directement `ox_target`, `qtarget` et `qb-target`.**<br>
Maintiens <kbd>Alt gauche</kbd>, fais un clic droit sur n'importe quoi dans le monde, et choisis une action.

<br>

[![FiveM](https://img.shields.io/badge/FiveM-resource-F26722?logo=fivem&logoColor=white)](https://fivem.net)
[![Lua](https://img.shields.io/badge/Lua-5.4-2C2D72?logo=lua&logoColor=white)](https://www.lua.org)
[![Standalone](https://img.shields.io/badge/framework-standalone-6e7681)](#%EF%B8%8F-configuration)
[![License](https://img.shields.io/badge/license-MIT-3fb950)](LICENSE)
[![Downloads](https://img.shields.io/github/downloads/ma3iich/pure-target/total?label=Downloads&color=2ea44f)](https://github.com/ma3iich/pure-target/releases)
[![YouTube](https://img.shields.io/badge/YouTube-%40ma3iich-red?logo=youtube&logoColor=white)](https://www.youtube.com/@ma3iich)
[![Discord](https://img.shields.io/badge/Discord-Support-5865F2?logo=discord&logoColor=white)](https://discord.gg/jJgtTScUYp)

**[⬇️ Télécharger](https://github.com/ma3iich/pure-target/releases/latest)** &nbsp;·&nbsp;
**[📦 Installation](#-installation)** &nbsp;·&nbsp;
**[⚙️ Configuration](#%EF%B8%8F-configuration)** &nbsp;·&nbsp;
**[❓ FAQ](#-faq)** &nbsp;·&nbsp;
**[📚 Exports](exports.md)** &nbsp;·&nbsp;
**[💬 Aide (Discord)](https://discord.gg/jJgtTScUYp)**

<sub>Fork d'<a href="https://www.youtube.com/watch?v=peS7m275vEY">Off-Target</a> par OffSey · Créé par <a href="https://github.com/ma3iich">ma3iich</a></sub>

</div>

---

## 🎬 Aperçu

<table>
  <tr>
    <th width="33%">🧍 Sur soi</th>
    <th width="33%">🚗 Sur un véhicule</th>
    <th width="33%">👥 Sur un autre joueur</th>
  </tr>
  <tr>
    <td><video src="https://github.com/user-attachments/assets/e1cf6a0d-8598-4378-b759-0e73077cf0ac" width="100%" controls muted></video></td>
    <td><video src="https://github.com/user-attachments/assets/3a4e1e92-412c-4db3-99e9-873c5bdfd65a" width="100%" controls muted></video></td>
    <td><video src="https://github.com/user-attachments/assets/72a18f0b-32a2-4ec7-91aa-7314a5673ad0" width="100%" controls muted></video></td>
  </tr>
</table>

> **ℹ️ Note**
>
> Les options visibles dans ces clips viennent des scripts de notre serveur, construits avec l'API de Pure-Target.
> Sur ton serveur, le menu affiche les options de **tes** propres scripts.

---

## ✨ Fonctionnalités

<table>
  <tr>
    <td width="50%">🖱️ <b>Menu clic droit</b><br><sub>À la place du classique « œil » : on maintient la touche, un curseur apparaît, on fait un clic droit sur ce qu'on veut.</sub></td>
    <td width="50%">🔌 <b>Remplace directement</b><br><sub><code>ox_target</code>, <code>qtarget</code> et <code>qb-target</code> : tes scripts actuels continuent de marcher, rien à modifier.</sub></td>
  </tr>
  <tr>
    <td>🧩 <b>Standalone</b><br><sub>Aucun framework, pas d'ox_lib, pas de base de données. QBox / QBCore / ESX sont détectés automatiquement pour les filtres de métier et d'objets.</sub></td>
    <td>🎯 <b>Ciblage précis</b><br><sub>Sélectionne exactement l'objet sous le curseur, même les props de la map sans collision propre (distributeurs muraux, mobilier encastré...).</sub></td>
  </tr>
  <tr>
    <td>📌 <b>Le menu reste ouvert</b><br><sub>Tant que la touche est maintenue : on ouvre plusieurs portes à la suite, les textes se mettent à jour en direct.</sub></td>
    <td>🚗 <b>Options véhicule intégrées</b><br><sub>Ouvrir / fermer la porte, le capot ou le coffre visé, baisser les fenêtres depuis l'intérieur (synchronisé par le serveur).</sub></td>
  </tr>
  <tr>
    <td>🎨 <b>Interface soignée</b><br><sub>Thème sombre au trait fin, ne sort jamais de l'écran, longues listes en colonnes, sous-menus, cases à cocher, bulles d'aide.</sub></td>
    <td>🌍 <b>13 langues</b><br><sub>EN, FR, DE, ES, IT, PT, NL, PL, TR, RU, ZH, JA, KO — facile d'en ajouter.</sub></td>
  </tr>
  <tr>
    <td>⚡ <b>Léger</b><br><sub>Aucune boucle ne tourne quand le menu est fermé ; le ciblage n'est calculé qu'au clic droit.</sub></td>
    <td>🛠️ <b>Sa propre API</b><br><sub>Crée tes menus : options, cases à cocher, sous-menus, séparateurs, lignes d'info.</sub></td>
  </tr>
</table>

## 🧭 Comment ça marche

<table>
  <tr>
    <td align="center" width="20%">⌨️<br><b>1. Maintiens Alt gauche</b><br><sub>un curseur apparaît</sub></td>
    <td align="center" width="20%">🖱️<br><b>2. Clic droit</b><br><sub>sur ce que tu vises</sub></td>
    <td align="center" width="20%">🎯<br><b>3. Ciblage précis</b><br><sub>un rayon trouve l'objet exact sous le curseur</sub></td>
    <td align="center" width="20%">🔎<br><b>4. Options vérifiées</b><br><sub>celles d'ox_target, qtarget, qb-target et Pure-Target</sub></td>
    <td align="center" width="20%">📋<br><b>5. Un seul menu</b><br><sub>tout est réuni, prêt à cliquer</sub></td>
  </tr>
</table>

---

## 📦 Installation

1. **[Télécharge `pure-target.zip`](https://github.com/ma3iich/pure-target/releases/latest)** et extrais-le dans tes `resources`.
2. Le dossier **doit s'appeler `pure-target`**.
3. Dans `server.cfg`, démarre-le **avant** les scripts qui utilisent un système de ciblage :

```cfg
ensure pure-target
```

> **⚠️ Attention**
>
> **Retire ou arrête** `ox_target`, `qtarget` et `qb-target` : Pure-Target les remplace
> (il déclare `provide 'ox_target'`, `provide 'qtarget'` et `provide 'qb-target'`).

> **❗ Important**
>
> **QBCore :** les scripts officiels de QBCore n'utilisent un système de ciblage que si `UseTarget` est activé.
> Ajoute cette ligne dans `server.cfg` (un serveur QBCore neuf a `setr UseTarget false`) :
> ```cfg
> setr UseTarget true
> ```

> **💡 Astuce**
>
> L'interface est déjà compilée (`web/build`) : rien à compiler.

**Prérequis :** un artefact de serveur FiveM récent (Lua 5.4, `cerulean`), OneSync conseillé pour la synchro des fenêtres.
En option : `ox_inventory`, `qbx_core`, `qb-core` ou `es_extended` pour les filtres `items` / `groups`.

---

## ⚙️ Configuration

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
| `CheckUpdates` | `true` | Au démarrage, le serveur regarde sur GitHub s'il existe une version plus récente et l'écrit dans la console (rien n'est téléchargé). |

<details>
<summary><b>Exemple : bloquer le menu quand le joueur est mort</b></summary>

```lua
Config.CanOpen = function()
    return not IsPauseMenuActive() and not IsEntityDead(PlayerPedId())
end
```

</details>

---

## 🛠️ Utilisation

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

> **💡 Astuce**
>
> D'autres exemples dans [`examples/`](examples/) (une ressource d'exemple prête à démarrer) et toutes les fonctions
> dans [`exports.md`](exports.md) (en anglais).

### Ajouts de Pure-Target aux options ox_target

| Champ | Effet |
| --- | --- |
| `group = 'Police'` | Les options d'un même groupe sont rangées dans un sous-menu (`groupIcon`, `groupColor`). |
| `description = '...'` | Bulle d'aide. |
| `closeOnClick = true` | Ferme le menu après cette option (par défaut : il reste ouvert tant que la touche est maintenue). |
| `addGlobalSelfPlayer` / `addGlobalOtherPlayer` | Options sur soi-même / sur les autres joueurs. |

---

## ⚖️ Différences avec ox_target

- Pas d'« œil » ni de détection au survol : les options sont calculées **une fois par clic droit**, c'est
  pour ça que la ressource ne coûte rien quand le menu est fermé.
- Le menu reste ouvert tant que la touche est maintenue (voir `closeOnClick`).
- Les menus imbriqués (`openMenu` / `menuName`) s'affichent comme des sous-menus.
- Champs d'option pris en charge : voir [`exports.md`](exports.md#option-schema).

## 🔒 Sécurité

> **❗ Important**
>
> `groups`, `items`, `distance` et `canInteract` décident seulement de ce qui est **affiché**. Un tricheur peut
> déclencher n'importe quel événement serveur avec n'importe quels arguments : tes scripts serveur doivent
> toujours vérifier eux-mêmes le métier, les objets, la distance, etc. L'option des fenêtres intégrée est
> vérifiée par le serveur (joueur assis dans ce véhicule, à la bonne place, limite de fréquence).

---

<details>
<summary><b>🎨 Compiler l'interface (seulement si tu la modifies)</b></summary>

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

Les couleurs du menu sont en haut de `web/src/features/contextMenu/style.scss`.

</details>

<details>
<summary><b>🗂️ Structure du projet</b></summary>

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

</details>

---

## ❓ FAQ

<div align="center">

[![Discord](https://img.shields.io/badge/Besoin%20d'aide%20%3F-Rejoins%20le%20Discord-5865F2?logo=discord&logoColor=white)](https://discord.gg/jJgtTScUYp)

<sub>Ta question n'est pas là ? Pose-la sur le Discord.</sub>

</div>

<details>
<summary><b>Le menu ne s'ouvre pas quand je maintiens Alt.</b></summary>

- Un autre script de ciblage tourne encore (`ox_target`, `qtarget`, `qb-target`) : retire-le ou arrête-le.
- Un autre script utilise déjà <kbd>Alt gauche</kbd> : change `Config.MenuKey` dans `shared/config.lua`, ou change la touche en jeu dans *Paramètres → Raccourcis clavier → FiveM*.
- Ton `Config.CanOpen` renvoie `false` (par exemple quand le joueur est mort).

</details>

<details>
<summary><b>Je dois modifier mes scripts ox_target / qb-target ?</b></summary>

Non. Pure-Target répond aux exports `ox_target`, `qtarget` et `qb-target` : tes scripts marchent tels quels.

</details>

<details>
<summary><b>Les options d'un de mes scripts n'apparaissent pas.</b></summary>

- Le dossier doit s'appeler exactement `pure-target`.
- `ensure pure-target` doit être **avant** ce script dans `server.cfg`.
- L'option utilise `groups` (métiers) et aucun framework n'a été trouvé : règle `Config.Framework` (`'qbx'`, `'qb'`, `'esx'`) dans `shared/config.lua`.
- Tu es trop loin : les options sans `distance` s'affichent jusqu'à 7 m du point cliqué (`Config.DefaultDistance`).
- Son `canInteract` renvoie `nil` ou `false` : comme avec ox_target, l'option est cachée.

</details>

<details>
<summary><b>J'ai redémarré pure-target et toutes les options ont disparu.</b></summary>

Chaque script enregistre ses options quand **il** démarre. Après `restart pure-target`, redémarre aussi les scripts qui l'utilisent, ou plus simplement tout le serveur.

</details>

<details>
<summary><b>Ça marche avec ESX, QBCore, QBox ou sans framework ?</b></summary>

Oui. QBox, QBCore et ESX sont détectés automatiquement pour les filtres `groups` et `items`, et il marche aussi sans aucun framework. Pour un autre framework, écris tes propres `Config.HasGroup` / `Config.GetItemCount`.

</details>

<details>
<summary><b>Je peux garder ox_target en même temps ?</b></summary>

Non. Pure-Target le remplace (`provide 'ox_target'`, `'qtarget'`, `'qb-target'`) : garde seulement Pure-Target.

</details>

<details>
<summary><b>Comment changer la langue, ou retirer les options portes / fenêtres ?</b></summary>

Dans `shared/config.lua` : `Config.Locale = 'fr'` (13 langues), et `Config.VehicleDoors = false` / `Config.VehicleWindows = false`.

</details>

<details>
<summary><b>Je peux changer les couleurs du menu ?</b></summary>

Oui : modifie les couleurs en haut de `web/src/features/contextMenu/style.scss`, puis recompile l'interface (`npm ci` puis `npm run build` dans `web/`).

</details>

<details>
<summary><b>Ça consomme des performances ?</b></summary>

Aucune boucle ne tourne quand le menu est fermé. Le ciblage n'est calculé qu'au moment du clic droit.

</details>

<details>
<summary><b>C'est sécurisé ?</b></summary>

Le menu décide seulement de ce qui est **affiché**. Comme avec ox_target, tes scripts serveur doivent toujours vérifier eux-mêmes le métier, les objets et la distance : un tricheur peut déclencher n'importe quel événement serveur directement.

</details>

<details>
<summary><b>Je peux le modifier, le partager ou l'utiliser sur mon serveur ?</b></summary>

Oui, il est sous licence MIT : libre d'utiliser, modifier et partager. Garde juste la mention de copyright du fichier `LICENSE`.

</details>

---

## 💖 Crédits

- **[ma3iich](https://github.com/ma3iich)** — auteur de Pure-Target.
- **[OffSey](https://www.youtube.com/watch?v=peS7m275vEY)** — Off-Target d'origine, dont Pure-Target est un fork.
- **[Kiminaze — ContextMenu](https://github.com/Kiminaze/ContextMenu)** — le menu clic droit d'origine, dont
  cette ressource suit le principe d'exports par identifiant.
- **[ox_target](https://github.com/overextended/ox_target)** (Overextended) et
  **[qtarget](https://github.com/overextended/qtarget)** — les API reproduites par les couches de compatibilité.
- Icônes : [Tabler Icons](https://tabler.io/icons) et [Font Awesome](https://fontawesome.com) (gratuites).

## 📄 Licence

[MIT](LICENSE) — libre d'utiliser, modifier et partager, en gardant la mention de copyright. Sans garantie.

<div align="center">

<br>

**Si Pure-Target t'aide sur ton serveur, laisse une ⭐ sur le dépôt !**

[![YouTube](https://img.shields.io/badge/YouTube-%40ma3iich-red?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/@ma3iich)
[![Discord](https://img.shields.io/badge/Discord-Support-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/jJgtTScUYp)
[![GitHub](https://img.shields.io/badge/GitHub-ma3iich-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/ma3iich)

</div>

</details>
<details name="langue" open>
<summary><picture><img src="https://img.shields.io/badge/Language-English-2ea44f?style=for-the-badge&labelColor=0D0D0D" alt="English"></picture></summary>

<div align="center">

<sub>🧩 <b>Pure suite</b> &nbsp;·&nbsp; <b>Pure-Target</b> (right-click menu) &nbsp;·&nbsp; <a href="https://github.com/ma3iich/pure_inventory">Pure Inventory</a> (inventory) &nbsp;—&nbsp; each one works standalone, and they work together</sub>


<img src="docs/banner.png" alt="Pure-Target — the right-click context menu for FiveM" width="100%">

<br>

**A standalone right-click context menu for FiveM — drop-in replacement for `ox_target`, `qtarget` and `qb-target`.**<br>
Hold <kbd>Left Alt</kbd>, right-click anything in the world, and act on it.

<br>

[![FiveM](https://img.shields.io/badge/FiveM-resource-F26722?logo=fivem&logoColor=white)](https://fivem.net)
[![Lua](https://img.shields.io/badge/Lua-5.4-2C2D72?logo=lua&logoColor=white)](https://www.lua.org)
[![Standalone](https://img.shields.io/badge/framework-standalone-6e7681)](#%EF%B8%8F-configuration-1)
[![License](https://img.shields.io/badge/license-MIT-3fb950)](LICENSE)
[![Downloads](https://img.shields.io/github/downloads/ma3iich/pure-target/total?label=Downloads&color=2ea44f)](https://github.com/ma3iich/pure-target/releases)
[![YouTube](https://img.shields.io/badge/YouTube-%40ma3iich-red?logo=youtube&logoColor=white)](https://www.youtube.com/@ma3iich)
[![Discord](https://img.shields.io/badge/Discord-Support-5865F2?logo=discord&logoColor=white)](https://discord.gg/jJgtTScUYp)

**[⬇️ Download](https://github.com/ma3iich/pure-target/releases/latest)** &nbsp;·&nbsp;
**[📦 Installation](#-installation-1)** &nbsp;·&nbsp;
**[⚙️ Configuration](#%EF%B8%8F-configuration-1)** &nbsp;·&nbsp;
**[❓ FAQ](#-faq-1)** &nbsp;·&nbsp;
**[📚 Exports](exports.md)** &nbsp;·&nbsp;
**[💬 Support](https://discord.gg/jJgtTScUYp)**

<sub>Fork of <a href="https://www.youtube.com/watch?v=peS7m275vEY">Off-Target</a> by OffSey · Made by <a href="https://github.com/ma3iich">ma3iich</a></sub>

</div>

---

## 🎬 Preview

<table>
  <tr>
    <th width="33%">🧍 On yourself</th>
    <th width="33%">🚗 On a vehicle</th>
    <th width="33%">👥 On another player</th>
  </tr>
  <tr>
    <td><video src="https://github.com/user-attachments/assets/e1cf6a0d-8598-4378-b759-0e73077cf0ac" width="100%" controls muted></video></td>
    <td><video src="https://github.com/user-attachments/assets/3a4e1e92-412c-4db3-99e9-873c5bdfd65a" width="100%" controls muted></video></td>
    <td><video src="https://github.com/user-attachments/assets/72a18f0b-32a2-4ec7-91aa-7314a5673ad0" width="100%" controls muted></video></td>
  </tr>
</table>

> **ℹ️ Note**
>
> The options shown in these clips come from our own server's scripts, built with Pure-Target's API.
> On your server, the menu shows the options of **your** scripts.

---

## ✨ Features

<table>
  <tr>
    <td width="50%">🖱️ <b>Right-click menu</b><br><sub>Instead of the classic "eye": hold the key, a cursor appears, right-click what you want.</sub></td>
    <td width="50%">🔌 <b>Drop-in replacement</b><br><sub>For <code>ox_target</code>, <code>qtarget</code> and <code>qb-target</code>: your existing scripts keep working, nothing to edit.</sub></td>
  </tr>
  <tr>
    <td>🧩 <b>Standalone</b><br><sub>No framework, no ox_lib, no database. QBox / QBCore / ESX are detected automatically for job and item filters.</sub></td>
    <td>🎯 <b>Precise targeting</b><br><sub>Picks the exact prop under the cursor, even map props without their own collision (wall ATMs, built-in furniture...).</sub></td>
  </tr>
  <tr>
    <td>📌 <b>Menu stays open</b><br><sub>While the key is held: open several doors in a row, labels update live.</sub></td>
    <td>🚗 <b>Built-in vehicle options</b><br><sub>Open / close the door, hood or trunk you click on, roll windows from inside (synced by the server).</sub></td>
  </tr>
  <tr>
    <td>🎨 <b>Clean UI</b><br><sub>Dark thin-line theme, never off screen, long lists in columns, submenus, checkboxes, tooltips.</sub></td>
    <td>🌍 <b>13 languages</b><br><sub>EN, FR, DE, ES, IT, PT, NL, PL, TR, RU, ZH, JA, KO — easy to add more.</sub></td>
  </tr>
  <tr>
    <td>⚡ <b>Light</b><br><sub>No loop runs while the menu is closed; targeting is computed on right-click only.</sub></td>
    <td>🛠️ <b>Its own API</b><br><sub>Build your own menus: items, checkboxes, submenus, separators, info rows.</sub></td>
  </tr>
</table>

## 🧭 How it works

<table>
  <tr>
    <td align="center" width="20%">⌨️<br><b>1. Hold Left Alt</b><br><sub>a cursor shows up</sub></td>
    <td align="center" width="20%">🖱️<br><b>2. Right-click</b><br><sub>on what you aim at</sub></td>
    <td align="center" width="20%">🎯<br><b>3. Precise targeting</b><br><sub>a raycast finds the exact object under the cursor</sub></td>
    <td align="center" width="20%">🔎<br><b>4. Options checked</b><br><sub>from ox_target, qtarget, qb-target and Pure-Target</sub></td>
    <td align="center" width="20%">📋<br><b>5. One menu</b><br><sub>everything merged, ready to click</sub></td>
  </tr>
</table>

---

## 📦 Installation

1. **[Download `pure-target.zip`](https://github.com/ma3iich/pure-target/releases/latest)** and extract it into your `resources`.
2. The folder **must be named `pure-target`**.
3. In `server.cfg`, start it **before** the scripts that use a target system:

```cfg
ensure pure-target
```

> **⚠️ Warning**
>
> **Remove or stop** `ox_target`, `qtarget` and `qb-target`: Pure-Target replaces them
> (it declares `provide 'ox_target'`, `provide 'qtarget'` and `provide 'qb-target'`).

> **❗ Important**
>
> **QBCore:** the official QBCore scripts only use a target system when `UseTarget` is enabled.
> Add this line to `server.cfg` (a fresh QBCore server has `setr UseTarget false`):
> ```cfg
> setr UseTarget true
> ```

> **💡 Tip**
>
> The UI is already built (`web/build`): nothing to compile.

**Requirements:** a recent FiveM server artifact (Lua 5.4, `cerulean`), OneSync recommended for the window sync.
Optional: `ox_inventory`, `qbx_core`, `qb-core` or `es_extended` for the `items` / `groups` filters.

---

## ⚙️ Configuration

Everything is in [`shared/config.lua`](shared/config.lua):

| Key | Default | Description |
| --- | --- | --- |
| `MenuKey` | `'LMENU'` | Key held to show the cursor. Players can rebind it in *Settings → Key Bindings → FiveM*. |
| `Locale` | `'en'` | Language of the built-in options: `en`, `fr`, `de`, `es`, `it`, `pt`, `nl`, `pl`, `tr`, `ru`, `zh`, `ja`, `ko` (add yours in `shared/locales.lua`). |
| `RaycastDistance` | `300.0` | Max raycast distance. |
| `DefaultDistance` | `7.0` | Distance of options without a `distance` field (ox_target default). |
| `MarkerClickRadius` | `18` | Click radius (pixels) of zone markers. |
| `MarkerDrawDistance` | `7.0` | Max distance zone markers are drawn at. |
| `Framework` | `'auto'` | `'auto'`, `'qbx'`, `'qb'`, `'esx'` or `'none'`. |
| `HasGroup` / `GetItemCount` | `nil` | Your own functions for other frameworks. |
| `CanOpen` | function | Return `false` to block the menu (dead, handcuffed...). |
| `IgnoreVehicleModels` | `{}` | Vehicle models handled as plain objects (e.g. wheelchairs). |
| `VehicleDoors` | `true` | Built-in door / hood / trunk options. |
| `VehicleWindows` | `true` | Built-in window options. |
| `CheckUpdates` | `true` | At start, the server checks GitHub for a newer release and prints a line in the console (nothing is downloaded). |

<details>
<summary><b>Example: block the menu while dead</b></summary>

```lua
Config.CanOpen = function()
    return not IsPauseMenuActive() and not IsEntityDead(PlayerPedId())
end
```

</details>

---

## 🛠️ Usage

### With ox_target (unchanged code)

```lua
exports.ox_target:addModel('prop_atm_01', {
    {
        name = 'atm:use',
        label = 'Use ATM',
        icon = 'fa-solid fa-credit-card',
        distance = 2.0,
        onSelect = function(data)
            print('ATM clicked', data.entity)
        end,
    },
})
```

### With the Pure-Target API

```lua
local ContextMenu = exports['pure-target']

ContextMenu:Register(function(entity, entityType, worldPos, hit)
    if not hit or entity ~= PlayerPedId() then return end

    local id = ContextMenu:AddItem(0, 'Hands up', 'fa-solid fa-hand')
    ContextMenu:OnActivate(id, function()
        TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_HANDS_UP', 0, true)
    end)
end)
```

> **💡 Tip**
>
> More in [`examples/`](examples/) (a ready-to-start example resource) and every export in [`exports.md`](exports.md).

### Pure-Target extensions to ox_target options

| Field | Effect |
| --- | --- |
| `group = 'Police'` | Options sharing a group are put in a submenu (`groupIcon`, `groupColor`). |
| `description = '...'` | Tooltip. |
| `closeOnClick = true` | Close the menu after this option (default: stays open while the key is held). |
| `addGlobalSelfPlayer` / `addGlobalOtherPlayer` | Options on yourself / on other players. |

---

## ⚖️ Differences with ox_target

- No "eye" and no hover detection: options are computed **once per right-click**, which is why the resource
  costs nothing while the menu is closed.
- The menu stays open while the key is held (see `closeOnClick`).
- Nested menus (`openMenu` / `menuName`) are shown as submenus.
- Supported option fields: see [`exports.md`](exports.md#option-schema).

## 🔒 Security

> **❗ Important**
>
> `groups`, `items`, `distance` and `canInteract` only decide what is **shown**. Any server event can be
> triggered by a cheater with any arguments: your server scripts must always check job, items, distance, etc.
> themselves. The built-in window option is checked server-side (player seated in that vehicle, right seat,
> rate limit).

---

<details>
<summary><b>🎨 Building the UI (only if you change it)</b></summary>

```bash
cd web
npm ci
npm run build
```

| Command | Description |
| --- | --- |
| `npm run dev` | Browser preview (right-click anywhere to open a demo menu). |
| `npm run build` | Production build into `web/build`. |
| `npm run game` | Rebuild on every change (`vite build --watch`). |

The colours of the menu are at the top of `web/src/features/contextMenu/style.scss`.

</details>

<details>
<summary><b>🗂️ Project structure</b></summary>

```
pure-target/
├─ fxmanifest.lua
├─ shared/
│  ├─ config.lua            # settings
│  └─ locales.lua           # texts of the built-in options
├─ client/
│  ├─ bridge.lua            # framework / inventory detection (groups, items)
│  ├─ core/                 # menu core, key binding, raycast
│  ├─ convert/              # ox_target, qtarget and qb-target layers
│  └─ modules/              # built-in vehicle doors & windows
├─ server/
│  └─ vehicle_windows.lua   # window sync (state bag), server checks
├─ examples/                # example resource
└─ web/                     # React (Vite) UI — build/ is served
```

</details>

---

## ❓ FAQ

<div align="center">

[![Discord](https://img.shields.io/badge/Need%20more%20help%3F-Join%20our%20Discord-5865F2?logo=discord&logoColor=white)](https://discord.gg/jJgtTScUYp)

<sub>Your question is not here? Ask it on the Discord.</sub>

</div>

<details>
<summary><b>The menu does not open when I hold Alt.</b></summary>

- Another target resource is still running (`ox_target`, `qtarget`, `qb-target`): remove or stop it.
- Another script already uses <kbd>Left Alt</kbd>: change `Config.MenuKey` in `shared/config.lua`, or rebind it in game in *Settings → Key Bindings → FiveM*.
- Your `Config.CanOpen` returns `false` (for example while dead).

</details>

<details>
<summary><b>Do I have to change my ox_target / qb-target scripts?</b></summary>

No. Pure-Target answers the `ox_target`, `qtarget` and `qb-target` exports, so your scripts keep working as they are.

</details>

<details>
<summary><b>The options of one of my scripts do not show up.</b></summary>

- The folder must be named exactly `pure-target`.
- `ensure pure-target` must be **before** that script in `server.cfg`.
- The option uses `groups` (jobs) and no framework was found: set `Config.Framework` (`'qbx'`, `'qb'`, `'esx'`) in `shared/config.lua`.
- You are too far: options without a `distance` are shown up to 7 m from the point you click (`Config.DefaultDistance`).
- Its `canInteract` returns `nil` or `false`: like ox_target, the option is hidden.

</details>

<details>
<summary><b>I restarted pure-target and every option disappeared.</b></summary>

Options are registered by each script when **that script** starts. After `restart pure-target`, restart the scripts that use it too, or simply restart the whole server.

</details>

<details>
<summary><b>Does it work with ESX, QBCore, QBox or without a framework?</b></summary>

Yes. QBox, QBCore and ESX are detected automatically for the `groups` and `items` filters, and it also works with no framework at all. For another framework, write your own `Config.HasGroup` / `Config.GetItemCount`.

</details>

<details>
<summary><b>Can I run ox_target and Pure-Target at the same time?</b></summary>

No. Pure-Target replaces them (`provide 'ox_target'`, `'qtarget'`, `'qb-target'`): keep only Pure-Target.

</details>

<details>
<summary><b>How do I change the language, or remove the door / window options?</b></summary>

In `shared/config.lua`: `Config.Locale = 'fr'` (13 languages), and `Config.VehicleDoors = false` / `Config.VehicleWindows = false`.

</details>

<details>
<summary><b>Can I change the colours of the menu?</b></summary>

Yes: edit the colours at the top of `web/src/features/contextMenu/style.scss`, then rebuild the UI (`npm ci` then `npm run build` in `web/`).

</details>

<details>
<summary><b>Does it cost performance?</b></summary>

No loop runs while the menu is closed. Targeting is only computed when you right-click.

</details>

<details>
<summary><b>Is it secure?</b></summary>

The menu only decides what is **shown**. Like with ox_target, your server scripts must always check job, items and distance themselves: a cheater can trigger any server event directly.

</details>

<details>
<summary><b>Can I modify it, share it or use it on my server?</b></summary>

Yes, it is MIT licensed: free to use, modify and share. Just keep the copyright notice in `LICENSE`.

</details>

---

## 💖 Credits

- **[ma3iich](https://github.com/ma3iich)** — author of Pure-Target.
- **[OffSey](https://www.youtube.com/watch?v=peS7m275vEY)** — original Off-Target, which Pure-Target is a fork of.
- **[Kiminaze — ContextMenu](https://github.com/Kiminaze/ContextMenu)** — the original right-click context
  menu whose ID-based export design this resource follows.
- **[ox_target](https://github.com/overextended/ox_target)** (Overextended) and
  **[qtarget](https://github.com/overextended/qtarget)** — the APIs mirrored by the compatibility layers.
- Icons: [Tabler Icons](https://tabler.io/icons) and [Font Awesome](https://fontawesome.com) (free).

## 📄 License

[MIT](LICENSE) — free to use, modify and share, keep the copyright notice. No warranty.

<div align="center">

<br>

**If Pure-Target helps your server, leave a ⭐ on the repository!**

[![YouTube](https://img.shields.io/badge/YouTube-%40ma3iich-red?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/@ma3iich)
[![Discord](https://img.shields.io/badge/Discord-Support-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/jJgtTScUYp)
[![GitHub](https://img.shields.io/badge/GitHub-ma3iich-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/ma3iich)

</div>

</details>
