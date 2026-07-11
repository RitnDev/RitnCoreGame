---
title: Dossier de passation — RitnCoreGame
mod: RitnCoreGame
profile: provider + extension + consumer
factorio_version: "2.0"
pinned_version: 0.6.10
audit_date: 2026-07-11
---

# Dossier de passation — RitnCoreGame

> Contrat de sortie de la skill 1 (audit). Contient tout ce dont la skill 2 (annotations LuaLS) et la
> skill 3 (documentation) ont besoin **sans ré-auditer**. Faits vérifiés uniquement ; `(hypothèse)` /
> `(à confirmer)` sinon. Exemples toujours sourcés `Mod/chemin.lua:ligne`.

## A. Métadonnées & périmètre

- **Profil** : **Provider** (interface remote `RitnCoreGame`) + **Extension** (étend RitnLib) +
  **Consumer** (events Factorio, `remote.call` sortant `freeplay`). Cœur de niveau 2 de l'empilement
  `RitnLib → RitnCoreGame → mods gameplay`.
- **Dépendances** (`info.json`) : `base`, `RitnLib >= 0.9`, `! space-exploration`, `! warptorio2`.
- **Arborescence explorée** (16 fichiers `.lua`) :
  - `control.lua`, `data-final-fixes.lua`
  - `core/` : `defines`, `setup-classes`, `modules`, `functions`, `migrations`
  - `classes/` : `RitnEvent`, `RitnForce`, `RitnPlayer`, `RitnSurface`
  - `modules/` : `storage`, `events`, `commands`, `player`, `force`, `surface`
  - `mods/` : `seablock`, `spaceblock`
- **Zones exclues** : `graphics/`, `sounds/`, `thumbnail.png` (assets) → aucune annotation/doc.
- **Renvoi** : voir `docs/architecture.md` (audit mainteneur, même repo).

---

## B. Pour la skill 2 — surface d'API à annoter (LuaLS)

> RitnLib est déjà annoté (voir `RitnLib/classes/**` et `RitnLib/types/ritnlib-globals.lua`), avec une
> **convention bilingue FR+EN** (`---**EN**` … `---──────` … `---**FR**` puis `@class/@field/@param/@return`).
> **Reproduire exactement cette convention.** RitnCoreGame n'a **pas encore** de meta-file de globals.

### B.1 Table des cibles

| Fichier | Symbole | Nature | Hérite de | Accès | Miroir meta-file ? | Statut |
|---|---|---|---|---|---|---|
| `classes/RitnEvent.lua` | `RitnCoreEvent` | classe (global `_G`) | `RitnLibEvent` | global | oui → créer `types/ritncoregame-globals.lua` | à annoter |
| `classes/RitnForce.lua` | `RitnCoreForce` | classe (global `_G`) | `RitnLibForce` | global | oui | à annoter |
| `classes/RitnPlayer.lua` | `RitnCorePlayer` | classe (global `_G`) | `RitnLibPlayer` | global | oui | à annoter |
| `classes/RitnSurface.lua` | `RitnCoreSurface` | classe (global `_G`) | `RitnLibSurface` | global | oui | à annoter |
| `core/functions.lua` | `flib` (`tableBusy`, `saveMapSettings`) | module (`local … return`) | — | `require` | non | à annoter |
| `core/migrations.lua` | `migration.version` | module | — | `require` | non | à annoter (⚠ défaut `e`) |
| `core/defines.lua` | `ritnlib.defines.core` | table d'alias (chaînes) | — | global (branche `ritnlib`) | non (structure de données) | annoter en `@class RitnCoreDefines` (hypothèse de nom) |
| `modules/storage.lua` | `core_interface` | table de fonctions remote | — | `remote` | non (mais documenter les signatures, cf. §C.3) | à annoter (signatures des fns remote) |
| `modules/{player,surface,force,events}.lua` | handlers `local function` | fonctions d'event | — | interne | non | annotation légère (`@param e EventData`) |
| `mods/seablock.lua`, `mods/spaceblock.lua` | `seablock`, module spaceblock | modules d'intégration | — | `require`/`remote` | non | à annoter (helpers) |
| `modules/commands.lua` | — | `return {}` | — | — | — | **stub** — note « vide, placeholder » |

- **Nature globale `_G`** : les 4 classes `RitnCore*` sont assignées à des globals (pas de `local … return`)
  → **doivent figurer dans le meta-file** `types/ritncoregame-globals.lua` (à créer, sur le modèle de
  `RitnLib/types/ritnlib-globals.lua`).
- **Constantes héritées à NE PAS redéclarer** comme si locales : `FORCE_PLAYER_NAME`, `FORCE_ENEMY_NAME`,
  `FORCE_NEUTRAL_NAME`, `isPresent`, `object_name` viennent des parents RitnLib. Les classes Core ajoutent
  `FORCE_DEFAULT_NAME`, `prefix_lobby`, `lobby_name`, `data`, `data_player`, `data_force`, `data_surface`,
  `admin`, `isLobby`, `clear_item`, `gui_action`.

### B.2 Détail par classe (matière des `@field` / `@param` / `@return`)

#### `RitnCoreEvent : RitnLibEvent`
- **Champs ajoutés** : `prefix_lobby :: string` (snapshot `"lobby~"`), `FORCE_DEFAULT_NAME :: string`.
- **Méthodes** :
  - `:getSurface() → RitnCoreSurface` (override), `:getForce() → RitnCoreForce` (override),
    `:getPlayer() → RitnCorePlayer` (override).
  - `:generateLobby()` — effet de bord : pose des tiles + `destroy` entités ; gate `name` commence par `lobby~`.
  - `:createForceDefault() → self` — crée la force `force~default` si absente ; **mutation** `self.force`.

#### `RitnCoreForce : RitnLibForce`
- **Champs** : `data :: table` (copie de `storage.core.forces`), `data_player`, `data_force`,
  `FORCE_DEFAULT_NAME`. ⚠ `data*` sont des **snapshots** obtenus par `remote.call` au constructeur.
- **Méthodes** (toutes chaînables sauf indication) : `:length()`, `:isEnemy()`, `:isForceDefault()`,
  `.exists(force_name)` **statique** ⚠, `:new()`, `:create(force_name)`, `.delete(force_name)` **statique**,
  `:getException()/:setException(v)`, `:getFinish()/:setFinish(v)`, `:saveInventory(player,cursor?)`,
  `:loadInventory(player,cursor?)`, `:insertInventory(player)`, `:deleteInventory(player)`,
  `:addPlayer(player)`, `:removePlayer(player)`, `:listPlayers()`, `:update()`.
- **Avertissements factuels** :
  - ⚠ `.exists` et `.delete` sont **statiques** (`.` pas `:`) — annoter sans `self`. `.exists` a une
    branche `else` qui référence `self` (défaut latent, cf. §C.6).
  - ⚠ `:saveInventory`/`:loadInventory` s'appuient sur `RitnLibInventory` dans un `util.tryCatch` (erreurs loggées, non propagées).

#### `RitnCorePlayer : RitnLibPlayer`
- **Champs** : `object_name = "RitnCorePlayer"` (réécrit), `data`, `data_player`, `gui_action :: table`,
  `lobby_name :: string` (`"lobby~"..name`), `FORCE_DEFAULT_NAME`, `clear_item :: boolean` (option, défaut `true`).
- **Méthodes** : `:getSurface()/:getForce()` (override), `:changeSurface()`, `:changeForce()`, `:init()`,
  `:new(teleport?)`, `:online()`, `:isOnline()`, `:setOrigine(o)/:getOrigine()`, `:isOrigine()`, `:isOwner()`,
  `:isForceDefault()`, `:isLobby()`, `:positionTP(pointOrigine?)`, `:createLobby(teleport?)`, `:createSurface()`,
  `:setActive(v)`, `:teleport(position, surface, optDecalage?, pointOrigine?, cancelDead?)`, `:teleportLobby()`,
  `:clearCursor(item_name, msg_print)`, `:update()`.
- **Avertissements** :
  - ⚠ `:createLobby` / `:createSurface` sont gatées `script.level.level_name == "freeplay"` (partie du flux réel).
  - ⚠ `:createSurface` consomme `remote.call('freeplay','get_disable_crashsite')` + `crash_site` vanilla.

#### `RitnCoreSurface : RitnLibSurface`
- **Champs** : `admin :: boolean` (défaut `false`), `data`, `data_player`, `data_surface`,
  `prefix_lobby :: string`, `isLobby :: boolean` (calculé `startsWith(name,"lobby~")`).
- **Méthodes** : `:length()`, `:new(exception?)`, `:getException()/:setException(v)`, `:getFinish()/:setFinish(v)`,
  `:getAdmin()/:setAdmin(v)`, `:getOrigine()/:setOrigine(o)`, `:addPlayer(player)`, `:removePlayer(player)`,
  `.delete(surface_name)` **statique**, `:update()`.
- **Avertissements** : ⚠ plusieurs getters `error(name.." not init !")` si la surface n'est pas dans `data` —
  précondition à documenter (appeler `:new()` d'abord).

---

## C. Pour la skill 3 — matière de documentation

### C.1 Carte des classes (matière `overview`)

| Classe | Fichier | Wrappe / rôle | Accès | Hérite de | Description courte |
|---|---|---|---|---|---|
| `RitnCoreEvent` | classes/RitnEvent.lua | EventData + fabrique de wrappers Core | global | `RitnLibEvent` | Point d'entrée des handlers ; génère lobby & force par défaut |
| `RitnCoreForce` | classes/RitnForce.lua | `LuaForce` + persistance core | global | `RitnLibForce` | CRUD forces, inventaires, exceptions, joueurs |
| `RitnCorePlayer` | classes/RitnPlayer.lua | `LuaPlayer` + persistance core | global | `RitnLibPlayer` | Lobby, surface d'origine, téléportation, création de map |
| `RitnCoreSurface` | classes/RitnSurface.lua | `LuaSurface` + persistance core | global | `RitnLibSurface` | Exceptions, origine, joueurs, détection lobby |

### C.2 Détail par classe publique — voir §B.2 (mutualisé).
Points « pièges » à mettre en avant dans la doc :
- Wrappers **temporaires** (hérité de la discipline RitnLib) : ne jamais stocker dans `storage`,
  réinstancier dans chaque handler.
- `data`/`data_*` sont des **snapshots** issus de `remote.call` au moment de la construction — un
  second wrapper créé plus tard peut voir un état différent. `:update()` réécrit le snapshot complet.
- Cas god/editor : hérités de `RitnLibPlayer` (`character` peut être `nil`).

### C.3 Interface remote (le cœur provider)

**Fonctions exposées** — signatures observées ([modules/storage.lua](../../modules/storage.lua)) :

| Fonction | Paramètres | Retour | Effet de bord |
|---|---|---|---|
| `get_players/surfaces/forces/enemy` | — | table | lecture `storage.core.<x>` |
| `set_players/surfaces/forces/enemy` | `(table)` | — | écrit `storage.core.<x>` |
| `get_map_settings/get_map_gen_settings` | — | table | lecture |
| `set_map_settings/set_map_gen_settings` | `(table)` | — | écriture |
| `save_map_settings` | — | `map_gen_settings` | snapshot map + calcul seed (délègue `core/functions.saveMapSettings`) |
| `get_options/set_options` | `()` / `(table)` | table / — | lecture/écriture |
| `get_option` | `(option)` | any | lecture d'une option |
| `get_values` | `(parameter)` | number | compteur (`players/surfaces/forces`) |
| `set_values` | `(parameter, value)` | — | écrit un compteur |
| `isStart/starting` | — | bool / — | flag démarrage |
| `isCheatModeActivated/cheatModeActivated` | — | bool / — | flag cheat (auto-init `false`) |
| `isMultiplayer/setMultiplayer` | — | bool / — | flag multi (auto-init `false`) |
| `init_data` | `(data_name, data_value)` | — | pose `storage.core.datas[data_name]` |
| `get_data` | `(parameter)` | table | **copie** d'un template |
| `add_param_data` | `(data_name, param_name, value)` | — | ajoute un champ à un template |
| `spaceblock` | `(event)` | — | délègue `spaceblock.on_chunk_generated` |

**Consommateurs vérifiés (grep, hors RitnCoreGame)** — nb de fichiers appelant l'interface :
`RitnLobbyGame` (9), `RitnBaseGame` (5), `RitnCharacters` (4), `RitnPortal` (4), `RitnTeleporter` (4),
`RitnEnemy` (3), `RitnMenuButton` (0). Fonctions les plus appelées : `get_options` (30×), `set_options`
(21×), `get_surfaces` (16×), `get_enemy` (13×), `set_enemy`/`get_players`/`add_param_data` (10×).

**Remote call sortant** : `remote.call('freeplay','get_disable_crashsite')` — [classes/RitnPlayer.lua:252](../../classes/RitnPlayer.lua).

**Exemples d'usage réels sourcés** (classes Core côté consommateurs) :
- `RitnCoreEvent(e):getPlayer():createSurface()` — `RitnBaseGame/modules/lobby.lua:22,38`
- `rOldForce:saveInventory(rEvent.player)` puis `rNewForce:loadInventory/insertInventory(rEvent.player)` — `RitnBaseGame/modules/lobby.lua:60,67,73`
- `RitnCoreSurface(rPlayer.surface):addPlayer(rPlayer.player)` / `RitnCoreForce(...):addPlayer(...)` — `RitnBaseGame/modules/player.lua:16-17`
- `RitnCorePlayer(self.player):createSurface()` — `RitnLobbyGame/classes/RitnGuiLobby.lua:147`
- `RitnCorePlayer(...):teleport({0,0}, surface_name, true, nil, true)` — `RitnLobbyGame/classes/RitnGuiSurfaces.lua:188`
- `RitnCorePlayer(LuaPlayer):teleportLobby():setOrigine(string.TOKEN_EMPTY_STRING)` — `RitnLobbyGame/modules/commands.lua:120`
- Héritage direct : `newclass(RitnCoreForce, …)` (`RitnEnemy/classes/RitnForce.lua:5`), `newclass(RitnCoreSurface, …)` (RitnEnemy/RitnLobbyGame/RitnPortal/RitnTeleporter).

### C.4 Event Map
Voir `docs/architecture.md §8`. Résumé : 5 events joueur, 1 surface, 1 force, `on_init`,
`on_configuration_changed`. Aucun `on_nth_tick`, aucun custom event. Enregistrement via l'event listener
RitnLib (`add_libraries`), pas `script.on_event` direct.

### C.5 Persistence Map
Structure unique `storage.core` — voir `docs/architecture.md §7`. Pour chaque sous-table :

| Structure | Créée | Lue / écrite par | Cycle de vie | Risque |
|---|---|---|---|---|
| `datas.*` (templates) | `on_init` / `on_configuration_changed` | `get_data`/`init_data`/`add_param_data` | permanent | réinit partielle en config_changed (`force`,`force_player` seulement) `(à confirmer voulu)` |
| `players` | à la volée (`RitnCorePlayer:init`) | classes Player + consommateurs | par joueur | index par `player.index` |
| `surfaces` | `RitnCoreSurface:new` | classes Surface + consommateurs | par surface | getters `error` si non init |
| `forces` | `RitnCoreForce:new` | classes Force + consommateurs | par force | idem |
| `enemy`, `map_settings`, `map_gen_settings`, `options` | on_init / functions | interface remote | permanent | — |
| `values{players,surfaces,forces}` | on_init | `get/set_values` | compteurs | incrément/décrément manuel (dérive possible si create/delete asymétriques) `(à vérifier)` |
| flags `start/cheatModeActivated/multiplayer` | on_init | interface remote | permanent | auto-init défensive `false` |

`script.register_metatable` : **non utilisé**. Wrappers jamais persistés (données plates uniquement).

### C.6 Classification des défauts

**Défauts latents confirmés** :
| Classe/fn | Fichier | Mécanisme | Statut |
|---|---|---|---|
| `migration_0_6_7` | core/migrations.lua:34 | variable `e` non définie (globale `nil`) → `RitnCoreEvent(nil)` | latent — chemin `on_configuration_changed` quand `force~default` absente ; effet partiellement auto-corrigé par `createForceDefault` |
| `RitnCoreForce.exists` | classes/RitnForce.lua:47 | fonction statique dont la branche `else` référence `self` (`nil`) | latent — seulement si `force_name` non-string |

**Effets de bord mineurs** :
- `on_configuration_changed` appelle `migration.version(0,6,7)` **en dur** (rejoue à chaque config change,
  pas de comparaison de version). — core/events.lua:79
- `mods/spaceblock` : `.events[on_chunk_generated]` jamais branché (module absent de `core/modules.lua`).

**Code beta / inachevé (→ pages stub 🚧)** :
- `modules/commands.lua` = `return {}` (aucune commande).
- `core/defines.lua` : alias `class.gui = …classes.RitnGui` **sans fichier** `classes/RitnGui.lua`.

**Résidus API 1.x** : **aucun détecté dans RitnCoreGame** (la gestion `global→storage` est correcte pour
2.0 ; `game.get_player/get_surface` déjà adoptés en 0.6.9 — cf. changelog). Les résidus 1.x connus
(`created_entity`, statistics) sont **côté RitnLib**, déjà documentés là-bas — hors périmètre ici.

**Ce qui N'EST PAS un bug (contrats d'extension / héritage)** — à répéter explicitement en doc :
- `FORCE_PLAYER_NAME` non défini localement → hérité de `RitnLibForce.init` (`"player"`). Usage RitnForce.lua:240 correct, chemin exercé.
- `setHiddenSurface`, `onNauvis`, `isNauvis`, `isPresent`, `object_name`, `getReason` → hérités de RitnLib.

### C.7 Plan de documentation recommandé

**Tier 0 (stratégique)** :
1. Concept « magasin central + interface remote » (le cœur provider) et pourquoi les classes ne touchent
   jamais `storage` — s'appuyer sur `RitnLib/docs/concepts/remote-contract.md` et `delegated-persistence.md`.
2. Concept « empilement d'extensions » (RitnLib → Core → gameplay) avec l'exemple `RitnCoreSurface` (4 sous-classes).

**Tier 1 (référence)** :
3. Pages classes `RitnCoreSurface` (la plus étendue) → `RitnCoreForce` → `RitnCorePlayer` → `RitnCoreEvent`.
4. Référence de l'interface remote (§C.3) avec table consommateurs.
5. Persistence map (§C.5) + Event map (§C.4).
6. Pages `known-bugs` (§C.6 défauts latents) et `migration`/`debt` (appel migration hardcodé, stubs).

**Zones difficiles / à refactorer avant doc** :
- Le double chemin de création de `force~default` (events `on_player_created` **et** migration `on_configuration_changed`)
  mérite clarification avant d'être documenté.
- Le mécanisme de migration versionnée (hardcodé) : décider s'il faut le corriger avant de le documenter.

---

## D. Questions ouvertes pour Ritn

1. **`classes/RitnGui.lua`** est référencé (`core/defines.lua`) mais absent. Fichier à venir, ou alias à retirer ?
2. **`modules/commands.lua` vide** : commandes prévues plus tard, ou module à supprimer du chargement ?
3. **`migration.version(0,6,7)` hardcodé** dans `on_configuration_changed` : intentionnel (rejeu idempotent
   voulu) ou à remplacer par une comparaison de versions ?
4. **`mods/spaceblock` event non branché** : le pilotage par la fonction remote `spaceblock` est-il le seul
   voulu, ou faut-il inclure le module dans `core/modules.lua` ?
5. **Réinit partielle des templates** en `on_configuration_changed` (`force`/`force_player` seulement) :
   volontaire ?
6. **Meta-file globals** : confirmer le chemin cible `types/ritncoregame-globals.lua` (sur le modèle RitnLib)
   pour la skill 2.
7. **Périmètre écosystème** : `W:\git\Factorio\ecosystem-map.md` est inaccessible sur ce portable ; les repos
   sont mirrorés sous `C:\Users\ritn\Documents\GitHub\`. La fiche écosystème de RitnCoreGame reste **à
   reporter** (voir note de bas de ce dossier).

---

> **Note logistique (Phase 4)** : le fichier canonique `W:\git\Factorio\ecosystem-map.md` n'était pas
> accessible sur ce poste. Un **fragment portable et fusionnable** a été produit à la place :
> [`docs/audit/ecosystem-map.md`](ecosystem-map.md). Au prochain passage sur la machine principale,
> fusionner son contenu (registre, graphe des relations, conventions, modèle de format, fiche
> RitnCoreGame) dans le fichier canonique — **fusionner, ne pas écraser**.
