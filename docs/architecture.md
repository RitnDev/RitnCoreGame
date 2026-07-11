---
title: Architecture interne RitnCoreGame
audience: mainteneur
status: living
last_review: 2026-07-11
pinned_version: 0.6.10
---

# Architecture interne — RitnCoreGame

> Document interne mainteneur. Vue d'ensemble de la structure du code, des dépendances et des choix
> de conception. Mis à jour à chaque refactor structurel — section « Historique » en bas.
>
> Conventions : faits observés en clair ; `(hypothèse)` / `(à confirmer)` sinon. Références en liens
> GitHub versionnés sur le tag `0.6.10`.

---

## 1. Identité

| Aspect | Valeur |
|---|---|
| Nom | `RitnCoreGame` |
| Version épinglée | `0.6.10` |
| `factorio_version` | `2.0` |
| Traits (non exclusifs) | **Provider** (interface remote `RitnCoreGame`) · **Extension** (étend les classes de RitnLib) · **Consumer** (events + `remote.call` sortants) |
| Dépendances | `base`, `RitnLib >= 0.9`, `! space-exploration`, `! warptorio2` |
| Position dans l'empilement | `RitnLib` (base) → **`RitnCoreGame` (cœur)** → mods gameplay (RitnBaseGame, RitnLobbyGame, RitnEnemy, RitnPortal, RitnTeleporter, RitnCharacters) |

**Rôle** : cœur d'un système de jeu multi-surfaces / multi-forces. RitnCoreGame fournit (a) un **magasin
de données central** `storage.core` exposé via une interface remote, et (b) une famille de **classes
wrapper** (`RitnCoreSurface/Force/Player/Event`) qui étendent les wrappers de RitnLib en y branchant la
persistance du core. Les mods gameplay consomment l'un, l'autre, ou étendent encore les classes.

---

## 2. Vue d'ensemble en couches

```
                       ┌─────────────────────────────────────────────┐
   Mods gameplay       │ RitnBaseGame · RitnLobbyGame · RitnEnemy     │
   (niveau 3)          │ RitnPortal · RitnTeleporter · RitnCharacters │
                       └───────────────┬─────────────────────────────┘
                                       │  remote.call("RitnCoreGame", …)
                                       │  newclass(RitnCoreSurface/Force, …)
                       ┌───────────────▼─────────────────────────────┐
   RitnCoreGame        │  Classes : RitnCoreSurface/Force/Player/Event│
   (niveau 2)          │  Interface remote "RitnCoreGame" (storage)   │
                       │  Modules d'events : player/surface/force     │
                       │  core/functions · core/migrations · mods/*   │
                       └───────────────┬─────────────────────────────┘
                                       │  newclass(RitnLibSurface/Force/…)
                                       │  ritnlib.defines.* · classFactory
                       ┌───────────────▼─────────────────────────────┐
   RitnLib             │  classFactory · wrappers de base · event     │
   (niveau 1, base)    │  listener · defines (registre d'alias)       │
                       └─────────────────────────────────────────────┘
```

**Séparation forte** : les classes ne touchent **jamais** `storage` directement — elles passent
**exclusivement** par l'interface remote `RitnCoreGame`. Le seul fichier qui lit/écrit `storage.core`
est [`modules/storage.lua`](https://github.com/RitnDev/RitnCoreGame/blob/0.6.10/modules/storage.lua).

---

## 3. Entrypoints

| Stage | Fichier | Action |
|---|---|---|
| control | [`control.lua`](https://github.com/RitnDev/RitnCoreGame/blob/0.6.10/control.lua) | Charge `core/defines`, `setup-classes`, active `gvv` si présent, envoie les modules à l'event listener de RitnLib |
| control (sous-jacent) | [`core/defines.lua`](https://github.com/RitnDev/RitnCoreGame/blob/0.6.10/core/defines.lua) | Déclare le registre d'alias `ritnlib.defines.core` |
| control (sous-jacent) | [`core/setup-classes.lua`](https://github.com/RitnDev/RitnCoreGame/blob/0.6.10/core/setup-classes.lua) | Charge les classes de base RitnLib puis définit les classes `RitnCore*` |
| data-final-fixes | [`data-final-fixes.lua`](https://github.com/RitnDev/RitnCoreGame/blob/0.6.10/data-final-fixes.lua) | Patch d'icônes `spaceblock-water` si le mod `spaceblock` est actif |
| settings | — | *Aucun* — le mod n'a pas de stage settings propre |
| migrations | [`core/migrations.lua`](https://github.com/RitnDev/RitnCoreGame/blob/0.6.10/core/migrations.lua) | Migrations applicatives déclenchées **par code** depuis `on_configuration_changed` (pas de scripts `migrations/*.lua`) |

> **Absence structurelle affirmée** : pas de dossier `migrations/` (scripts moteur). Les migrations sont
> un mécanisme **applicatif interne** (`migration.version(major,minor,patch)`) invoqué manuellement.

---

## 4. Registre global / modules — `ritnlib.defines.core`

`core/defines.lua` attache un sous-registre `core` à la table globale `ritnlib.defines` (fournie par
RitnLib). Il ne contient **que des chaînes de chemins `require`** (résolus paresseusement) et des
constantes de nommage — aucune logique.

| Clé | Contenu |
|---|---|
| `class.{event,player,surface,force,gui}` | Chemins des classes `RitnCore*` (`gui` déclaré mais **aucun fichier `classes/RitnGui.lua`** — cf. §11) |
| `setup` | Chemin de `core/setup-classes` |
| `modules.{core,storage,events,commands,player,force,surface}` | Chemins des modules |
| `functions` | Chemin de `core/functions` |
| `mods.{seablock,spaceblock}` | Chemins des helpers d'intégration |
| `sounds.none` | `sounds/none.ogg` |
| `names.prefix.{enemy,lobby}` | `"enemy~"`, `"lobby~"` |
| `names.force_default` | `"force~default"` |

**Conventions de nommage runtime** (préfixes de surfaces/forces) :
- surfaces lobby : `lobby~<player>` ;
- force par défaut (« sas ») : `force~default` ;
- forces enemy : préfixe `enemy~` (constante déclarée ; usage réel côté RitnEnemy).

---

## 5. Système de classes

**Factory** : `ritnlib.classFactory.newclass(super?, init)` (RitnLib,
[`core/class.lua`](https://github.com/RitnDev/RitnLib/blob/master/classes/RitnClass/ClassFactory.lua)).
Copie **superficielle** des champs du parent dans l'enfant, pose `_super`, stocke le constructeur en
`.init`, et rend la classe appelable (`Classe(args)` → instance). Chaque instance reçoit `:is_a(klass)`
qui remonte la chaîne `_super`.

**Familles étendues** (chaque classe `RitnCore*` appelle explicitement `RitnLib<X>.init(self, …)` en
tête de son propre constructeur) :

| Classe RitnCore | Parent RitnLib | Ajouts principaux |
|---|---|---|
| `RitnCoreEvent` | `RitnLibEvent` | override `getSurface/getForce/getPlayer` (retournent les variantes Core), `generateLobby`, `createForceDefault` |
| `RitnCoreForce` | `RitnLibForce` | branche `self.data* = remote.call(…)`, CRUD forces, inventaires, exceptions, players |
| `RitnCorePlayer` | `RitnLibPlayer` | lobby, surface d'origine, téléportation, `createSurface` |
| `RitnCoreSurface` | `RitnLibSurface` | `isLobby`, exceptions, origine, players, admin |

**Hiérarchie d'héritage inter-mod observée (niveau 3)** :
- `RitnEnemyForce → RitnCoreForce → RitnLibForce`
- `RitnEnemySurface / RitnLobbySurface / RitnPortalSurface / RitnTeleporterSurface → RitnCoreSurface → RitnLibSurface`

> `RitnCoreSurface` est la classe **la plus étendue** de l'écosystème (4 sous-classes directes).

---

## 6. Flux d'exécution

**Bootstrap effectif (RitnCoreGame chargé seul)**
```
control.lua
  ├─ require core/defines           → ritnlib.defines.core (alias)
  ├─ require setup-classes          → require RitnLib base classes
  │                                    puis define RitnCoreSurface/Force/Player/Event
  ├─ (si gvv) require gvv()
  └─ RitnLib event listener.add_libraries( core/modules )
        └─ require { storage, events, commands, player, surface, force }
              └─ storage.lua : remote.add_interface("RitnCoreGame", core_interface)
```

**Cycle de vie runtime**
```
on_init (events.lua)                → init_data templates {player,surface,force,…} + options
on_configuration_changed (events)   → réinit template force, options, flags,
                                       migration.version(0,6,7)   [appel HARDCODÉ]
on_player_created (player.lua)       → setMultiplayer + createForceDefault si absente
on_surface_created / on_force_created→ cache les surfaces "lobby~" aux forces
on_player_changed_surface/force      → maj data joueur + cache surfaces
```

**Flux consommateur typique** (RitnBaseGame lobby, sourcé) :
```
RitnCoreEvent(e):getPlayer()            → RitnCorePlayer
   :createSurface()                     → game.create_surface + RitnCoreForce:create + teleport
rOldForce:saveInventory(player)         → sauvegarde inventaire dans data_force
rNewForce:loadInventory / insertInventory(player)
```

---

## 7. Persistance

Un **arbre unique** `storage.core`, créé dans
[`modules/storage.lua`](https://github.com/RitnDev/RitnCoreGame/blob/0.6.10/modules/storage.lua).

| Aspect | Statut |
|---|---|
| Racine | `storage.core = { datas, players, surfaces, forces, map_settings, map_gen_settings, enemy, options, values{players,surfaces,forces}, start, cheatModeActivated, multiplayer }` |
| Migration `global` → `storage` | Gérée : `if global ~= nil then storage = global end` (storage.lua:5) |
| Accès | **Uniquement** via l'interface remote `RitnCoreGame` (get/set). Les classes ne touchent jamais `storage`. |
| `script.register_metatable` | **Non utilisé** — les données stockées sont des tables plates (pas de méta-objet persisté). Les classes wrapper sont **temporaires**, jamais stockées. |
| Templates de données | `storage.core.datas.{player,surface,force,surface_player,force_player}` initialisés en `on_init` |
| Sémantique de copie | `remote.call` **sérialise/copie** ses retours → `get_data("force")` renvoie une **copie fraîche** du template à chaque instanciation ⇒ pas d'aliasing entre entités (mécanisme clé qui rend le réemploi du template sûr) |

> ⚠ Point de vigilance : les templates (`datas.*`) sont réinitialisés en `on_configuration_changed`
> pour `force` et `force_player` uniquement — pas `player`/`surface`. Comportement voulu `(à confirmer)`.

---

## 8. Évènements

Enregistrés via l'**event listener de RitnLib** (`add_libraries`), pas via `script.on_event` direct.

| Handler | Fichier | Rôle |
|---|---|---|
| `on_init` | modules/events.lua | Init templates + options |
| `on_configuration_changed` | modules/events.lua | Réinit partielle + `migration.version(0,6,7)` |
| `on_player_created` | modules/player.lua | `setMultiplayer`, `createForceDefault` |
| `on_player_cheat_mode_enabled` | modules/player.lua | flag `cheatModeActivated` |
| `on_player_changed_surface` | modules/player.lua | `RitnCorePlayer:changeSurface` |
| `on_player_changed_force` | modules/player.lua | `changeForce` + masquage surfaces |
| `on_pre_player_left_game` | modules/player.lua | log de départ (avec `getReason`) |
| `on_surface_created` | modules/surface.lua | cache les surfaces `lobby~` à toutes les forces |
| `on_force_created` | modules/force.lua | cache les surfaces `lobby~` à la nouvelle force |
| `on_chunk_generated` | mods/spaceblock.lua | génération spaceblock — **⚠ registration inerte** : le module `mods/spaceblock` n'est PAS inclus dans `core/modules.lua`, donc ce `.events[...]` n'est jamais branché ; spaceblock est en fait piloté par la fonction remote `spaceblock` |

- `on_nth_tick` : **aucun**.
- Custom events : **aucun** défini par RitnCoreGame.

---

## 9. Interfaces remote

### 9.1 Exposée — `remote.add_interface("RitnCoreGame", …)` (le cœur provider)

Définie dans [`modules/storage.lua`](https://github.com/RitnDev/RitnCoreGame/blob/0.6.10/modules/storage.lua).
~30 fonctions. Consommée par **6 des 7 mods gameplay** (tous sauf RitnMenuButton).

| Groupe | Fonctions |
|---|---|
| players | `get_players`, `set_players` |
| surfaces | `get_surfaces`, `set_surfaces` |
| forces | `get_forces`, `set_forces` |
| enemy | `get_enemy`, `set_enemy` |
| map | `get_map_settings`, `set_map_settings`, `get_map_gen_settings`, `set_map_gen_settings`, `save_map_settings` |
| options | `get_options`, `set_options`, `get_option` |
| values (compteurs) | `get_values`, `set_values` |
| flags | `isStart`, `starting`, `isCheatModeActivated`, `cheatModeActivated`, `isMultiplayer`, `setMultiplayer` |
| datas (templates) | `init_data`, `get_data`, `add_param_data` |
| intégration | `spaceblock` |

**Top consommateurs** (grep écosystème) : `get_options` (30), `set_options` (21), `get_surfaces` (16),
`get_enemy` (13), `set_enemy`/`get_players`/`add_param_data` (10). Détail par mod dans `docs/audit/handoff.md` §C.3.

### 9.2 Consommées (remote calls sortants)

| Cible | Fonction | Où | Note |
|---|---|---|---|
| `freeplay` | `get_disable_crashsite` | [RitnPlayer.lua:252](https://github.com/RitnDev/RitnCoreGame/blob/0.6.10/classes/RitnPlayer.lua#L252) | Scénario vanilla freeplay ; gate le crash site |
| `RitnCoreGame` (auto-appel) | `get_*/set_*` | classes/* | Les classes s'appellent elles-mêmes via l'interface — profite de la copie de `remote.call` |

---

## 10. APIs Factorio touchées

| Surface d'API | Où | Usage type |
|---|---|---|
| `game.create_force` / `LuaForce.reset/chart/set_friend/recipes/technologies` | RitnForce.lua, RitnEvent.lua | Création & configuration de forces |
| `game.create_surface` / `LuaSurface.set_tiles/destroy_decoratives/find_entities_filtered` | RitnPlayer.lua, RitnSurface.lua, RitnEvent.lua | Génération de surfaces (lobby, map joueur) |
| `LuaPlayer.teleport / clear_cursor / cursor_stack / ticks_to_respawn / character` | RitnPlayer.lua | Téléportation & gestion joueur |
| `force.set_surface_hidden` | modules/force.lua, modules/surface.lua, RitnLibForce | Masquage de surfaces lobby |
| `game.map_settings` / `nauvis.map_gen_settings` / `autoplace_controls` | core/functions.lua | Snapshot & personnalisation de la génération |
| `crash_site.create_crash_site` (lualib vanilla) | RitnPlayer.lua | Site de crash freeplay |
| `settings.startup` / `prototypes.item` (data & runtime) | mods/seablock.lua, mods/spaceblock.lua | Intégrations tierces |
| `data.raw.recipe/item` | data-final-fixes.lua | Patch d'icônes (data stage) |

---

## 11. Dette / erreurs résiduelles (synthèse)

> Classification complète et sourcée dans **`docs/audit/handoff.md` §C.6**. Résumé ici.

**Défauts latents confirmés** (vérifiés en source ; chemins peu ou pas exercés) :
1. `migration_0_6_7()` référence une variable **`e` non définie** (globale `nil`) —
   [core/migrations.lua:34](https://github.com/RitnDev/RitnCoreGame/blob/0.6.10/core/migrations.lua#L34).
   Copié-collé de `modules/player.lua:on_player_created` (qui reçoit `e` en paramètre). La fonction de
   migration ne prend aucun paramètre. Effet runtime partiellement auto-corrigé par `createForceDefault`,
   mais fragile.
2. `RitnCoreForce.exists(force_name)` — fonction **statique** (`.exists`), mais sa branche `else`
   log `self.object_name` → `self` global `nil` → erreur. Ne se déclenche que si `force_name` n'est pas
   une string. [classes/RitnForce.lua:47](https://github.com/RitnDev/RitnCoreGame/blob/0.6.10/classes/RitnForce.lua#L47).

**Effets de bord / observations** :
- `on_configuration_changed` appelle `migration.version(0,6,7)` **en dur** — la migration 0.6.7 rejoue à
  chaque changement de config, sans comparer l'ancienne/nouvelle version (`e.mod_changes` ignoré).
- Module `mods/spaceblock` : son `.events[on_chunk_generated]` n'est jamais branché (module absent de
  `core/modules.lua`) — registration inerte, cf. §8.

**Code beta / stub** :
- [`modules/commands.lua`](https://github.com/RitnDev/RitnCoreGame/blob/0.6.10/modules/commands.lua)
  = `return {}` (aucune commande) — placeholder chargé mais vide.
- `core/defines.lua` déclare `class.gui = …classes.RitnGui` mais **aucun fichier `classes/RitnGui.lua`
  n'existe** — alias vers une classe non fournie (chargé paresseusement, donc inerte tant que non requis).

**Ce qui N'EST PAS un bug (contrats d'extension / héritage)** :
- `self.FORCE_PLAYER_NAME` (RitnForce.lua:240) → constante `"player"` **héritée** de `RitnLibForce.init`.
  Non défini localement ≠ défaut. Chemin réellement exercé (RitnBaseGame lobby).
- `setHiddenSurface`, `onNauvis`, `isNauvis`, `isPresent`, `getReason` → **méthodes/champs hérités** de RitnLib.

---

## 12. Sortie attendue post-refactor

| Version | Vague | Contenu envisagé |
|---|---|---|
| `0.6.x` | Correctifs latents | Corriger `e` dans `migration_0_6_7` ; rendre `.exists` robuste (retirer `self`) ; brancher ou retirer la registration `mods/spaceblock` |
| `0.6.x` | Migration versionnée | Remplacer l'appel `migration.version(0,6,7)` codé en dur par une comparaison `old→new` sur `e.mod_changes` |
| `0.7.0` | Nettoyage stubs | Statuer sur `RitnGui` (fichier manquant) et `commands` vide |
| `0.7.x` | Annotations LuaLS | Skill 2 : annoter la surface d'API (voir handoff §B) |
| `0.7.x` | Documentation | Skill 3 : doc bilingue (voir handoff §C) |

---

## Historique

| Date | Version pin | Changement |
|---|---|---|
| 2026-07-11 | 0.6.10 | Document initial (audit Phase 1–4, pipeline skill 1) |
