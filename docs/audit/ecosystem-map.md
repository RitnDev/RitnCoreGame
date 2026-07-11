# Écosystème Factorio — carte vivante (fragment portable)

> ⚠ **Ceci est un FRAGMENT embarqué**, produit lors de l'audit de RitnCoreGame sur un poste où le
> fichier canonique `W:\git\Factorio\ecosystem-map.md` n'était pas accessible.
>
> **Protocole de fusion** (à faire sur la machine principale) : reporter les entrées ci-dessous dans
> `W:\git\Factorio\ecosystem-map.md` — **fusionner, ne pas écraser**. Ne conserver que les faits vérifiés ;
> les lignes `(à auditer)` / `(à confirmer)` sont des amorces, pas des vérités à graver.
>
> **Portée** : mods de Ritn uniquement. Faits vérifiés par lecture de code / grep pendant l'audit
> RitnCoreGame `0.6.10` (2026-07-11). Repos mirrorés sous `C:\Users\ritn\Documents\GitHub\` sur ce poste.

## Registre des mods

| Mod | Chemin (poste principal) | Traits | Rôle en une ligne | Audité | Annoté | Documenté |
|---|---|---|---|---|---|---|
| RitnLib | `W:\git\Factorio\RitnLib` | socle / library | classFactory + wrappers de base + event listener + defines | oui (préexistant) | oui | oui (mkdocs) |
| **RitnCoreGame** | `W:\git\Factorio\RitnCoreGame` | provider + extension + consumer | cœur : magasin `storage.core` via remote + classes Core | **oui (2026-07-11)** | non | non |
| RitnBaseGame | `W:\git\Factorio\RitnBaseGame` | consumer + extension | gameplay lobby/base ; consomme le core, instancie les classes Core | non | non | non |
| RitnLobbyGame | `W:\git\Factorio\RitnLobbyGame` | consumer + extension | GUI lobby & sélection de surfaces ; étend `RitnCoreSurface` | non | non | non |
| RitnEnemy | `W:\git\Factorio\RitnEnemy` | consumer + extension | gestion des forces/surfaces enemy ; étend `RitnCoreForce`/`RitnCoreSurface` | non | non | non |
| RitnPortal | `W:\git\Factorio\RitnPortal` | consumer + extension | portails inter-surfaces ; étend `RitnCoreSurface` | non | non | non |
| RitnTeleporter | `W:\git\Factorio\RitnTeleporter` | consumer + extension | téléporteurs ; étend `RitnCoreSurface` | non | non | non |
| RitnCharacters | `W:\git\Factorio\RitnCharacters` | consumer | personnages ; consomme le core (remote) | non | non | non |
| RitnMenuButton | `W:\git\Factorio\RitnMenuButton` | consumer | bouton de menu ; instancie des classes Core (pas d'appel remote détecté) | non | non | non |

> Repos non-Ritn présents localement (hors périmètre, ne pas auditer) : `gvv` (dépendance/debug externe).

## Graphe des relations

- **RitnCoreGame étend** les classes de **RitnLib** (héritage inter-mod) — preuve :
  `RitnCoreGame/classes/RitnForce.lua:8` `newclass(RitnLibForce, …)`, idem Player/Surface/Event.
- **RitnCoreGame fournit** l'interface remote `RitnCoreGame` (~30 fns) à : RitnLobbyGame (9 fichiers),
  RitnBaseGame (5), RitnCharacters (4), RitnPortal (4), RitnTeleporter (4), RitnEnemy (3).
  Fonctions les plus consommées : `get_options` (30×), `set_options` (21×), `get_surfaces` (16×),
  `get_enemy` (13×).
- **RitnEnemy étend `RitnCoreForce`** — preuve : `RitnEnemy/classes/RitnForce.lua:5` `newclass(RitnCoreForce, …)`.
- **RitnEnemy / RitnLobbyGame / RitnPortal / RitnTeleporter étendent `RitnCoreSurface`** — preuves :
  `RitnEnemy/classes/RitnSurface.lua:5`, `RitnLobbyGame/classes/RitnSurface.lua:5`,
  `RitnPortal/classes/RitnSurface.lua:11`, `RitnTeleporter/classes/RitnSurface.lua:7`.
- **RitnCoreGame consomme** l'interface remote `freeplay` : `get_disable_crashsite` — preuve :
  `RitnCoreGame/classes/RitnPlayer.lua:252`.

Chaîne d'empilement confirmée : **RitnLib → RitnCoreGame → {RitnEnemy, RitnLobbyGame, RitnPortal, RitnTeleporter}**.
`RitnCoreSurface` est la classe la plus étendue (4 sous-classes directes).

## Conventions partagées observées (multi-mods)

> Confirmées dans **au moins** RitnLib + RitnCoreGame (+ consommateurs quand indiqué).

- **Factory de classes** `ritnlib.classFactory.newclass(super?, init)` (copie superficielle du parent,
  `_super`, `:is_a()`) — RitnLib (définition), RitnCoreGame + RitnEnemy/RitnLobbyGame/RitnPortal/RitnTeleporter (usage).
- **Registre d'alias `ritnlib.defines.*`** : chaque mod attache son sous-registre de chemins `require`
  (RitnCoreGame → `ritnlib.defines.core`). Vérifié RitnLib + RitnCoreGame.
- **Persistance déléguée via interface remote** (les classes ne touchent jamais `storage`) — RitnCoreGame ;
  concept documenté dans `RitnLib/docs/concepts/delegated-persistence.md` et `remote-contract.md`.
- **Wrappers temporaires** (ne jamais stocker dans `storage`, réinstancier par handler) — RitnLib (doctrine
  annotée) + RitnCoreGame (hérité).
- **Event listener RitnLib** (`add_libraries`) au lieu de `script.on_event` direct — RitnLib + RitnCoreGame.
- **Migration `global → storage`** (`if global ~= nil then storage = global end`) — RitnCoreGame ; `(à confirmer)` ailleurs.
- **changelog.txt strict** (format Factorio) + **CI GitHub Actions** (tag → release → upload portail) — RitnCoreGame ;
  `(à confirmer)` généralisé.
- **Doc bilingue FR+EN** avec bloc `---**EN** … ──── ---**FR**` puis annotations LuaLS — RitnLib (référence).

## Modèle de format

**RitnLib** — seul mod déjà entièrement documenté (`docs/` : ADR, concepts, guides, debt ; `mkdocs.yml` ;
`types/ritnlib-globals.lua` ; annotations LuaLS bilingues dans `classes/**`). À utiliser comme **référence
de style** pour les audits/annotations/docs des autres mods.

## Fiches par mod

### RitnCoreGame
- **Profil réel** : provider + extension + consumer. `factorio_version` `2.0`. Dépendances : `base`,
  `RitnLib >= 0.9`, `! space-exploration`, `! warptorio2`.
- **Spécificités propres** :
  - Magasin central unique `storage.core` exposé par l'interface remote `RitnCoreGame` (le cœur).
  - 4 classes Core étendant RitnLib ; `RitnCoreSurface` est le point d'extension principal du gameplay.
  - Migrations **applicatives** (`migration.version(major,minor,patch)`), pas de dossier `migrations/`.
  - Pas de `script.register_metatable`, pas de `on_nth_tick`, pas de custom event.
- **Renvois** : `RitnCoreGame/docs/architecture.md`, `RitnCoreGame/docs/audit/handoff.md`.
- **Questions ouvertes** : voir handoff §D (fichier `RitnGui.lua` manquant, `commands.lua` vide,
  `migration.version(0,6,7)` hardcodé, event `mods/spaceblock` non branché, réinit partielle des templates).

### RitnLib *(non ré-audité ici — infos glanées en support de l'audit RitnCoreGame)*
- Socle : `classFactory` (`core/class.lua`), wrappers `RitnLib{Event,Force,Player,Surface,...}`, `defines.lua`,
  `types/ritnlib-globals.lua`. Résidus 1.x connus documentés côté RitnLib (`created_entity`, statistics `getStats*`).
- Statut : audité/annoté/documenté (préexistant). Fiche complète à compléter lors d'un audit dédié.

### Autres consommateurs *(à auditer)*
RitnBaseGame, RitnLobbyGame, RitnEnemy, RitnPortal, RitnTeleporter, RitnCharacters, RitnMenuButton :
relations au core vérifiées ci-dessus, mais **profil interne non audité**. Fiches à créer lors de leurs audits.
