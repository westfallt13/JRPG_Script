# JRPG Framework (GDScript) - WORK IN PROGRESS

A modular RPG systems framework hand-written in GDScript for use with the Godot Engine. This repository contains reusable building blocks for character stats, item databases, and related RPG mechanics.

### Note: As this is a work in progress and it is intended to transform into a giant build, it will contain bugs, especially if it's an unfinished section. To find notes on dev, look in the guide.md files throughout the repository, or (see [DEVLOGS.md](Documentation/DEVLOGS.md) for latest updates)

## About

This framework was developed as the backbone of a personal JRPG project. The core systems are generic enough to be dropped into any Godot RPG project. Some files have been intentionally excluded from this repository — they contain game-specific content (story, world data, balancing) that is private to the author's game.

What is here is free for anyone to use, adapt, or build on.

## Installation Guide (see [INSTALLATION_GUIDE.md](Documentation/INSTALLATION_GUIDE.md) for details)

## Structure

```
data/
  db_loader/
    json_db.gd                         # JsonDB — static JSON read/index helpers
    db_loader.gd                       # DbLoader autoload — central data access point
    equipment_effects.gd               # EquipmentEffects — item -> effect resolver
    guide.to.db.loader.md
  item_database/
    consumables/
      consumables.gd                   # Consumable loader (reads JSON/)
      JSON/                            # One .json file per consumable
      consumable_effect/               # Subfolders: health, mana_restoration, stat_buffs
      consumable_type/                 # Consumable type classifications
    equipment/
      accessories/
        guide_to_accessories.md
        accessory_effects/             # Effect definitions for accessories
        l_ring/
          dict.l_ring.gd               # Left ring slot
          guide_to_left_rings.md
        necklace/
          dict.necklaces.gd            # Necklace slot
          guide_to_necklaces.md
        r_ring/
          dict.r_ring.gd               # Right ring slot
          guide_to_right_rings.md
      armor/
        armor_effects/                 # Effect definitions for armor
          guide_to_armor_effects.md
        armor_types/
          boots/dict.boots.gd          # Boot slot definitions
          bottoms/dict.bottoms.gd      # Pants/bottoms slot definitions
          chests/dict.chests.gd        # Chest armor slot definitions
          gloves/dict.gloves.gd        # Glove slot definitions
          helmet/dict.helmets.gd       # Helmet slot definitions
      weapons/
        weapon_effects/                # Per-type effect dictionaries (axe, bow, dagger, etc.)
        weapon_types/                  # Per-type stat dictionaries (axe, bow, dagger, etc.)
    quest_items/
      guide_to_quest_items.md
      quest_items.gd                   # Quest-specific item registry (3 placeholder items)
    usable_items/                      # Non-consumable usable items
      Guide_To_Usable_Items.md
      defensive_items/
        Guide_To_Defensive_Items.md
      offensive_items/
        Guide_To_Offensive_Items.md
      support_items/
  stats/                               # Loader + JSON/ categories, same pattern as items
    ability_and_stability/
      ability_types/
        magic_abilities/magic_abilities.gd     # Loader: "magic_abilities" (reads JSON/)
        enemy_abilities/enemy_abilities.gd     # Loader: "enemy_abilities" (reads JSON/)
    enemy_stats/                       # Reserved for enemy stat blocks
    level_ups/
      level_ups.gd                     # class_name Leveling — XP & level-up logic
      level_value_database/
        level_value_database.gd        # Loader: "level_curve" — XP thresholds + per-level gains
        JSON/default_curve.json        # public default curve
        level_curves/                  # private per-character curves (excluded from commits)
    stat_types/
      attributes/attribute_stats.gd            # Loader: "attributes" — 6 core stats (reads JSON/)
      health_and_mana/health_and_mana.gd        # Loader: "health_and_mana" — HP/MP pools (reads JSON/)
      health_and_mana/health_and_mana_helper_functions/  # HP/MP utility stubs
    status_conditions/
      status_conditions.gd                     # Loader: "status_conditions" — 10 conditions (reads JSON/)
      status_condition_helper_functions/        # Status effect application stubs
tools/
  smoke_test.gd                        # EditorScript: load every category, print counts
```

## Systems

### Data Loading (`data/db_loader/`)
All game data is authored as JSON and accessed through a single autoloaded singleton — gameplay code never reads files directly.
- **`DbLoader`** (`db_loader.gd`, autoload) — central access point. `get_category(name)` returns a category as a name-keyed dictionary; `get_item(category, key)` fetches one entry; `load_all()` warms everything (e.g. on a loading screen). Categories load lazily and are cached.
- **`JsonDB`** (`json_db.gd`) — static JSON helpers shared by every loader: `read_json`, `index_by`, `load_dir`, `load_collection`.
- **`EquipmentEffects`** (`equipment_effects.gd`) — resolves an equipment item's named effects into full effect data. `EquipmentEffects.for_item_key("swords", name)` returns the effect objects to feed UI text, attribute math, and damage/status logic.
- **`EffectResolver`** (`effect_resolver.gd`) — folds resolved effects into per-stat modifiers via each effect's `kind`/`target`/`op`, applied as `(base + Σadd) × (1 + Σmult)`. The `Combatant` uses it for gear-aware stats.
- **Adding content** — each leaf data folder has a loader `.gd` plus a `JSON/` subfolder. Drop a `.json` file in `JSON/` to add an item; no code changes. Items reference effects by name (`weapon_effect` / `armor_effects` / `accessory_effects`), resolved against the matching effects collection.

### Stats (`data/stats/`)
The stat systems use the **same loader + `JSON/` pattern** as the item database and are reached through `DbLoader.get_category(...)`. They hold **template defaults**; a character's live values will live on the Combatant (see the dev plan). Each is a JSON collection (array under a root key, keyed by a name field) plus a tiny `get_all()` loader.
- **Attributes** (`DbLoader.get_category("attributes")`) — six core stats `strength`, `intelligence`, `vitality`, `willpower`, `agility`, `luck`, each `{ attribute_name, base_value, description }` with `base_value` 10
- **Health & Mana** (`DbLoader.get_category("health_and_mana")`) — pool defaults `max_health`, `current_health`, `max_mana`, `current_mana` (all 100), keyed by `stat_name`
- **Status Conditions** (`DbLoader.get_category("status_conditions")`) — 10 conditions (`Poison`, `Burn`, `Paralyzed`, etc.) keyed by `status_name`, classified as `damage_over_time` or `status_effect`
- **Magic / Enemy Abilities** (`DbLoader.get_category("magic_abilities")`, `"enemy_abilities"`) — element/type-tagged ability definitions (one test placeholder each, ready to fill)
- **Leveling** (`level_ups/level_ups.gd` = `class_name Leveling`; curve via `DbLoader.get_category("level_curve")`) — `Leveling.grant_xp(combatant, amount)` adds XP and applies every level-up crossed, growing attributes and HP/MP from `default_curve.json` (`{ level, xp_to_reach, gains }`). Numbers in JSON, math in code; a private per-character curve can be passed in instead.

### Item Database (`data/item_database/`)
- **Equipment/Weapons** — 7 weapon types (sword, axe, dagger, knife, greatsword, bow, staff), each with `weapon_class` (one-handed/two-handed) and a `weapon_effect` field naming effects resolved against that type's `weapon_effects/` collection
- **Equipment/Armor** — 5 slot types (helmet, chest, bottoms, gloves, boots) each with `armor_class` (light/medium/heavy) and an optional `armor_effects` field; all share the `armor_effects/` collection (defines `defense_boost`, `magic_resistance`)
- **Equipment/Accessories** — left ring, right ring, and necklace slots; share the `accessory_effects/` collection
- **Consumables** — loader keyed by `consumable_name`, reads its `JSON/` folder (empty scaffolding, ready to fill)
- **Quest Items** — 3 entries (Ancient Amulet, Enchanted Sword, Mystic Scroll), one `.json` per item, keyed by `name`
- **Usable Items** — non-consumable usable items split into defensive, offensive, and support categories; loaders in place, `JSON/` folders ready to fill

### Combatant (`data/combatant/`)
- **`Combatant`** (`combatant.gd`, `class_name`) — one entity's **live state**: base attributes, HP/MP pools, equipment per slot, and active statuses, seeded from the stat templates via `Combatant.from_templates(name, level)`. This is the glue that ties the data layer to gameplay (templates are shared defaults; a Combatant holds the per-character values that change in play).
- **Equipment** — `equip(slot, category, key)` stores each item's category alongside its key, so effects resolve per category. Slots: weapon, helmet, chest, bottoms, gloves, boots, l_ring, r_ring, necklace.
- **`build_context()`** — the single place wearer-side context keys are produced (via `BattleContext`), so conditions always see `wearer_statuses`, never a bare `statuses`.
- **`active_equipment_effects()`** — resolves every equipped item's condition-filtered effects against the combatant's own context (e.g. the Test Sword's `low_hp_rage` activates only below 30% HP). `total_stat(stat)` / `derived_stat(stat, base)` fold those into numbers via `EffectResolver` — the Test Sword raises `crit_chance` by 0.15, and adds +25% damage only below 30% HP.
- **Leveling** — tracks `level`/`xp`; `Leveling.grant_xp(hero, 300)` applies the level-ups it crosses, and `gain_level(gains)` grows base attributes and HP/MP pools (gear modifiers still stack on top via `total_stat`).

### Tooling (`tools/`)
- **`smoke_test.gd`** — an `EditorScript` that loads every `DbLoader` category and prints a per-category item count + total. **File ▸ Run** (`Ctrl+Shift+X`); watch the Output panel for counts and load warnings.
- **`combatant_test.gd`** — an `EditorScript` of PASS/FAIL checks for the autoload-free surface (Combatant seeding, equip, statuses, `build_context`; and `EffectResolver` aggregation). Same run flow.
- **`node_2dtestdb.gd`** (the main scene's script) — run the project with **F5** to exercise the live, gear-resolving path (`from_templates`, `active_equipment_effects`, `total_stat`, `validate`) with the real `DbLoader` autoload.

## What's Excluded

Certain files are not included in this repository because they contain content specific to the author's game (lore, specific item lists, ability details, etc.). These are listed in `.gitignore`. The framework files above are designed to work independently of that content.

## Requirements

- [Godot Engine](https://godotengine.org/) (GDScript)

## License

This project is released under a **Non-Commercial Use License**. See [LICENSE](LICENSE) for the full terms.

- **Free to use** for personal, educational, and non-profit projects.
- **Commercial use requires a paid license.** Contact thomas.westfall@beachfall.studio to arrange one.
