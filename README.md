# JRPG Framework (GDScript) - WORK IN PROGRESS

A modular RPG systems framework hand-written in GDScript for use with the Godot Engine. This repository contains reusable building blocks for character stats, item databases, and related RPG mechanics.

## About

This framework was developed as the backbone of a personal JRPG project. The core systems are generic enough to be dropped into any Godot RPG project. Some files have been intentionally excluded from this repository — they contain game-specific content (story, world data, balancing) that is private to the author's game.

What is here is free for anyone to use, adapt, or build on.

## Structure

```
data/
  item_database/
    consumables/
      consumables.gd                   # Consumable item registry (syntax fix needed)
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

### Stats (`data/stats/`)
- **Attributes** (`stat_types/attributes/attribute_stats.gd`) — six core stats: `strength`, `intelligence`, `vitality`, `willpower`, `agility`, `luck`, all defaulting to 10
- **Health & Mana** (`stat_types/health_and_mana/health_and_mana.gd`) — `current_health`, `max_health`, `current_mana`, `max_mana` pools; currently has a syntax error (values defined outside the dictionary brackets)
- **Status Conditions** (`status_conditions/status_conditions.gd`) — 10 keyed conditions (`Poison`, `Burn`, `Paralyzed`, etc.) classified as `damage_over_time` or `status_effect`

### Item Database (`data/item_database/`)
- **Equipment/Weapons** — 7 weapon types (sword, axe, dagger, knife, greatsword, bow, staff), each with `weapon_class` (one-handed/two-handed) and `weapon_effect` fields; paired effect dictionaries in `weapon_effects/`
- **Equipment/Armor** — 5 slot types (helmet, chest, bottoms, gloves, boots) each with `armor_class` (light/medium/heavy) fields; `armor_effects/` folder reserved for proc effects
- **Equipment/Accessories** — left ring, right ring, and necklace slots; `accessory_effects/` reserved for proc effects
- **Consumables** — registry skeleton with subfolders for health, mana restoration, and stat buff effects; currently has a syntax error (`inv` instead of `var`)
- **Quest Items** — 3 placeholder entries (Ancient Amulet, Enchanted Sword, Mystic Scroll) keyed by `quest_id`
- **Usable Items** — non-consumable usable items split into defensive, offensive, and support categories; all empty scaffolding

## What's Excluded

Certain files are not included in this repository because they contain content specific to the author's game (lore, specific item lists, ability details, etc.). These are listed in `.gitignore`. The framework files above are designed to work independently of that content.

## Requirements

- [Godot Engine](https://godotengine.org/) (GDScript)

## License

This project is released under a **Non-Commercial Use License**. See [LICENSE](LICENSE) for the full terms.

- **Free to use** for personal, educational, and non-profit projects.
- **Commercial use requires a paid license.** Contact thomas.westfall@beachfall.studio to arrange one.
