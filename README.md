# JRPG Framework (GDScript) - WORK IN PROGRESS

A modular RPG systems framework hand-written in GDScript for use with the Godot Engine. This repository contains reusable building blocks for character stats, item databases, and related RPG mechanics.

## About

This framework was developed as the backbone of a personal JRPG project. The core systems are generic enough to be dropped into any Godot RPG project. Some files have been intentionally excluded from this repository — they contain game-specific content (story, world data, balancing) that is private to the author's game.

What is here is free for anyone to use, adapt, or build on.

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
  stats/
    ability_and_stability/
      enemy_abilities/                 # Reserved for enemy ability definitions
      magic_abilities/                 # Reserved for spell data
    enemy_stats/                       # Reserved for enemy stat blocks
    level_ups/
      level_curves/                    # Character level-up curves (excluded from commits)
      level_value_database/            # Level-up stat value database
        guide.to.level.value.database.md
    stat_types/
      attributes/attribute_stats.gd            # 6 core character attributes
      health_and_mana/health_and_mana.gd        # HP/MP pools (syntax fix needed)
      health_and_mana/health_and_mana_helper_functions/  # HP/MP utility stubs
    status_conditions/
      status_conditions.gd                     # 10 status effects
      status_condition_helper_functions/        # Status effect application stubs
```

## Systems

### Data Loading (`data/db_loader/`)
All game data is authored as JSON and accessed through a single autoloaded singleton — gameplay code never reads files directly.
- **`DbLoader`** (`db_loader.gd`, autoload) — central access point. `get_category(name)` returns a category as a name-keyed dictionary; `get_item(category, key)` fetches one entry; `load_all()` warms everything (e.g. on a loading screen). Categories load lazily and are cached.
- **`JsonDB`** (`json_db.gd`) — static JSON helpers shared by every loader: `read_json`, `index_by`, `load_dir`, `load_collection`.
- **`EquipmentEffects`** (`equipment_effects.gd`) — resolves an equipment item's named effects into full effect data. `EquipmentEffects.for_item_key("swords", name)` returns the effect objects to feed UI text, attribute math, and damage/status logic.
- **Adding content** — each leaf data folder has a loader `.gd` plus a `JSON/` subfolder. Drop a `.json` file in `JSON/` to add an item; no code changes. Items reference effects by name (`weapon_effect` / `armor_effects` / `accessory_effects`), resolved against the matching effects collection.

### Stats (`data/stats/`)
- **Attributes** (`stat_types/attributes/attribute_stats.gd`) — six core stats: `strength`, `intelligence`, `vitality`, `willpower`, `agility`, `luck`, all defaulting to 10
- **Health & Mana** (`stat_types/health_and_mana/health_and_mana.gd`) — `current_health`, `max_health`, `current_mana`, `max_mana` pools; currently has a syntax error (values defined outside the dictionary brackets)
- **Status Conditions** (`status_conditions/status_conditions.gd`) — 10 keyed conditions (`Poison`, `Burn`, `Paralyzed`, etc.) classified as `damage_over_time` or `status_effect`

### Item Database (`data/item_database/`)
- **Equipment/Weapons** — 7 weapon types (sword, axe, dagger, knife, greatsword, bow, staff), each with `weapon_class` (one-handed/two-handed) and a `weapon_effect` field naming effects resolved against that type's `weapon_effects/` collection
- **Equipment/Armor** — 5 slot types (helmet, chest, bottoms, gloves, boots) each with `armor_class` (light/medium/heavy) and an optional `armor_effects` field; all share the `armor_effects/` collection (defines `defense_boost`, `magic_resistance`)
- **Equipment/Accessories** — left ring, right ring, and necklace slots; share the `accessory_effects/` collection
- **Consumables** — loader keyed by `consumable_name`, reads its `JSON/` folder (empty scaffolding, ready to fill)
- **Quest Items** — 3 entries (Ancient Amulet, Enchanted Sword, Mystic Scroll), one `.json` per item, keyed by `name`
- **Usable Items** — non-consumable usable items split into defensive, offensive, and support categories; loaders in place, `JSON/` folders ready to fill

## What's Excluded

Certain files are not included in this repository because they contain content specific to the author's game (lore, specific item lists, ability details, etc.). These are listed in `.gitignore`. The framework files above are designed to work independently of that content.

## Requirements

- [Godot Engine](https://godotengine.org/) (GDScript)

## License

This project is released under a **Non-Commercial Use License**. See [LICENSE](LICENSE) for the full terms.

- **Free to use** for personal, educational, and non-profit projects.
- **Commercial use requires a paid license.** Contact thomas.westfall@beachfall.studio to arrange one.
