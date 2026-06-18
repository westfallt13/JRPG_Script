# JRPG_Script — Data Folder Structure

## `data/` — Root data directory. All static game data lives here, split into items and stats.

---

### `data/item_database/` — Item and equipment definitions for the game's inventory system.

#### `data/item_database/equipment/` — All equippable gear the player can obtain and use.

---

#### `data/item_database/equipment/armor/` — Armor slot definitions and class system.
| File | Purpose |
|------|---------|
| [armor_master.gd](data/item_database/equipment/armor/armor_master.gd) | Defines the full armor equipment structure: all slots (helmet, chest, pants, boots, hands, accessories) and the three armor class tiers (light, medium, heavy). Accessories include ring slots (left/right) and necklace, with hooks for future effects. Currently a structural skeleton — no actual armor items populated yet. |
| `armor_master.gd.uid` | Godot internal UID used to track this resource across the project. Do not edit manually. |

---

#### `data/item_database/equipment/consumables/` — Consumable items (potions, food, etc.)
| File | Purpose |
|------|---------|
| [consumables.gd](data/item_database/equipment/consumables/consumables.gd) | Placeholder file for consumable item definitions. Empty — ready to be populated with potions, elixirs, food, etc. |
| `consumables.gd.uid` | Godot internal UID for this resource. |

---

#### `data/item_database/equipment/quest_items/` — Non-equippable story and quest items.
| File | Purpose |
|------|---------|
| [quest_items.gd](data/item_database/equipment/quest_items/quest_items.gd) | Placeholder for quest-specific items (keys, story artifacts, collectibles). Empty — structure pending. |
| `quest_items.gd.uid` | Godot internal UID for this resource. |

---

#### `data/item_database/equipment/weapons/` — Master weapon registry and all weapon data.
| File | Purpose |
|------|---------|
| [weapons_master.gd](data/item_database/equipment/weapons/weapons_master.gd) | The top-level weapon registry. Defines the 7 weapon type categories (greatsword, sword, dagger, knife, axe, bow, staff) with planned support for per-character equip restrictions. Has `weapon_type` and `weapon_name` keys. Acts as the authoritative lookup table for all weapon definitions. Extends Node. |
| [weapons_master2.gd](data/item_database/equipment/weapons/weapons_master2.gd) | Secondary / experimental weapons master dictionary. Appears to be a scratchpad or work-in-progress alternative to `weapons_master.gd`. Currently empty. |
| `weapons_master.gd.uid` | Godot internal UID for `weapons_master.gd`. |

---

#### `data/item_database/equipment/weapons/weapon_types/` — Per-weapon-type data dictionaries (stats, names, descriptions).
Each subfolder holds one `.gd` file defining a dictionary for that weapon category. All are currently empty scaffolding.

| Folder / File | Purpose |
|------|---------|
| `axe/dictionary_axes.gd` | Axe weapon definitions — intended to hold axe items with their stats and metadata. |
| `bow/dictionary_bow.gd` | Bow weapon definitions — intended to hold bow items with their stats and metadata. |
| `dagger/dictionary_dagger.gd` | Dagger weapon definitions — intended to hold dagger items with their stats and metadata. |
| `greatswords/dictionary_greatswords.gd` | Greatsword weapon definitions  — intended to hold greatsword items with their stats and metadata. ||
| `knife/dictionary_knives.gd` | Knife weapon definitions — intended to hold knife items with their stats and metadata. | |
| `staff/dictionary_staves.gd` | Staff weapon definitions — intended to hold staff items with their stats and metadata. | |
| `sword/dictionary_swords.gd` | Sword weapon definitions — intended to hold sword items with their stats and metadata. | |

---

#### `data/item_database/equipment/weapons/weapon_effects/` — Per-weapon-type special effect dictionaries.
Mirrors the `weapon_types/` structure but stores the *effects* that each weapon category can proc or apply (e.g., bleed on axes, magic on staves). All currently empty.

| Folder / File | Purpose |
|------|---------|
| `axe/dictionary_axe_effects.gd` | Special effects for axes (e.g., cleave, bleed). |
| `bow/dictionary_bow_effects.gd` | Special effects for bows (e.g., pierce, slow). |
| `dagger/dictionary_dagger_effects.gd` | Special effects for daggers (e.g., poison, backstab). |
| `greatswords/dictionary_greatswords_effects.gd` | Special effects for greatswords (e.g., knockback, stun). |
| `knife/dictionary_knives_effects.gd` | Special effects for knives. |
| `staff/dictionary_staves_effects.gd` | Special effects for staves (e.g., spell amplification). |
| `sword/dictionary_swords_effects.gd` | Special effects for swords. |

---

### `data/stats/` — All character stat systems: attributes, HP/MP, mental state, and status conditions.

---

#### `data/stats/stat_types/` — Core numerical stats that define a character's capabilities.

##### `data/stats/stat_types/attributes/`
| File | Purpose |
|------|---------|
| [attribute_stats.gd](data/stats/stat_types/attributes/attribute_stats.gd) | Defines the 6 core character attributes: `strength`, `intelligence`, `vitality`, `willpower`, `agility`, `luck` — all defaulting to 10. Intended to be merged into party member dictionaries with a `name_` prefix for identification. |

##### `data/stats/stat_types/health_and_mana/`
| File | Purpose |
|------|---------|
| [health_and_mana.gd](data/stats/stat_types/health_and_mana/health_and_mana.gd) | Defines `current_health`, `max_health`, `current_mana`, `max_mana` (all default 100). **Note:** The current file has a syntax error — the health/mana values are defined outside the dictionary brackets. Needs a fix before it can be used. |
| `health_and_mana_helper_functions/health_and_mana_helper_functions.gd` | Placeholder for HP/MP utility functions (healing, damage application, mana consumption, etc.). Empty — logic pending. |

---

#### `data/stats/ability_and_stability/` — Emotional/mental character states and ability definitions.

##### `data/stats/ability_and_stability/mental_state/`
| File | Purpose |
|------|---------|
| [mental_state.gd](data/stats/ability_and_stability/mental_state/mental_state.gd) | Defines 8 psychological/emotional states that affect gameplay: **Trust, Hatred, Despair, Hope, Fear, Courage, Pride, Shame** — each with a named ability and description (e.g., "Hope's Light" restores 30% HP, "Shame's Curse" increases damage taken by 25%). This is the mental state / emotional system that drives character behavior and combat modifiers. |
| `mental_state.gd.uid` | Godot internal UID for this resource. |

##### `data/stats/ability_and_stability/enemy_abilities/` — *(Empty)* Reserved for unique enemy ability definitions.
##### `data/stats/ability_and_stability/magic_abilities/` — *(Empty)* Reserved for spell and magic ability data.
##### `data/stats/ability_and_stability/mental_abilities/` — *(Empty)* Reserved for mental/psychic skill definitions.

---

#### `data/stats/status_conditions/` — Debuffs and conditions that can be applied to characters.
| File | Purpose |
|------|---------|
| [status_conditions.gd](data/stats/status_conditions/status_conditions.gd) | Defines 10 status effects: **Poison, Silenced, Sleep, Burn, Cursed, Frozen, Paralyzed, Confused, Bleeding, Stunned** — each classified as either `damage_over_time` or `status_effect`. Keyed by name so they can be looked up directly (e.g., `status_conditions["Poison"]`). Detailed effect values marked for future expansion. |
| `status_condition_helper_functions/status_condition_helper_functions.gd` | Contains a stub `apply_status_condition(target, condition)` function — the entry point for applying status effects to characters. Logic not yet implemented. |

---

#### `data/stats/enemy_stats/` — *(Empty)* Reserved for enemy-specific stat blocks and definitions.

#### `data/stats/stats.gd.uid` — Godot UID remnant from a deleted `stats.gd` root file. Safe to remove once the project is cleaned up.
