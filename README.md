# JRPG Framework (GDScript)

A modular RPG systems framework written in GDScript for use with the Godot Engine. This repository contains reusable building blocks for character stats, item databases, and related RPG mechanics.

## About

This framework was developed as the backbone of a personal JRPG project. The core systems are generic enough to be dropped into any Godot RPG project. Some files have been intentionally excluded from this repository — they contain game-specific content (story, world data, balancing) that is private to the author's game.

What is here is free for anyone to use, adapt, or build on.

## Structure

```
data/
  item_database/
    item_database.gd          # Item schema definition (name, type, weight, equippable flag, etc.)
    item_dictionary_array.gd  # Array-backed item registry with add/get helpers
  stats/
    stats.gd                  # Character attributes, health/mana pools, and status conditions
```

## Systems

### Stats (`data/stats/stats.gd`)
- **Health & Mana** — current/max pools with a `heal()` helper that clamps to max
- **Attributes** — six core stats: `strength`, `intelligence`, `vitality`, `willpower`, `agility`, `luck`
- **Status Conditions** — keyed dictionary of conditions (`Poison`, `Burn`, `Paralyzed`, etc.) with a `condition_type` field distinguishing damage-over-time from status effects

### Item Database (`data/item_database/`)
- `item_database.gd` — defines the item schema: name, description, quantity, weight, total weight, equippable flag, and an extensible `item_type` block for consumables, quest items, and equipment
- `item_dictionary_array.gd` — a simple array-backed registry with `add_item()` and `get_item()` functions for looking up items by name

## What's Excluded

Certain files are not included in this repository because they contain content specific to the author's game (lore, specific item lists, ability details, etc.). These are listed in `.gitignore`. The framework files above are designed to work independently of that content.

## Requirements

- [Godot Engine](https://godotengine.org/) (GDScript)

## License

This project is released under a **Non-Commercial Use License**. See [LICENSE](LICENSE) for the full terms.

- **Free to use** for personal, educational, and non-profit projects.
- **Commercial use requires a paid license.** Contact thomas.westfall@beachfall.studio to arrange one.
