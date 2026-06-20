# DB Loader — Usage Guide

How to read game data from anywhere in the project. The three scripts in this
folder do all the work; you only ever call into them.

- **`DbLoader`** (autoload) — the front door. Ask it for items/categories.
- **`JsonDB`** (`class_name`, global) — the JSON helpers `DbLoader`'s subloaders use. You rarely call this directly.
- **`EquipmentEffects`** (`class_name`, global) — resolves an item's named effects into full effect data.
- **`ConditionChecker`** (`class_name`, global) — decides whether an effect applies in a given situation.

Only `DbLoader` is in the autoload list. `JsonDB`, `EquipmentEffects`, and
`ConditionChecker` are reachable everywhere by name because they use `class_name`.

---

## DbLoader — accessing item data

### Get one whole category (name-keyed Dictionary)
```gdscript
var swords := DbLoader.get_category("swords")
# { "Test Sword": { "sword_name": "Test Sword", ... }, ... }
```

### Get one specific item
```gdscript
var sword = DbLoader.get_item("swords", "Test Sword")   # the item Dictionary, or null
if sword != null:
    print(sword["description"])
```

### Read a specific field off an item
```gdscript
var sword := DbLoader.get_item("swords", "Test Sword") as Dictionary
print(sword["sword_name"])                 # "Test Sword"
print(sword["weapon_class"]["one_handed"]) # nested field
var two_h: bool = sword.get("weapon_class", {}).get("two_handed", false)  # safe access
```

### List every item in a category (e.g. to fill a menu)
```gdscript
for item in DbLoader.get_category("helmets").values():
    add_menu_row(item["helmets_name"], item["description"])

# Just the names/keys:
var names := DbLoader.get_category("helmets").keys()
```

### Several categories at once
```gdscript
var weapons := DbLoader.get_categories(["swords", "axes", "bows"])
# { "swords": {...}, "axes": {...}, "bows": {...} }
```

### Other helpers
```gdscript
DbLoader.category_names()   # every category name it knows about
DbLoader.load_all()        # force-load everything now (e.g. on a loading screen)
DbLoader.reload("swords")  # drop one category from cache; re-reads on next access
DbLoader.clear_cache()     # drop all cached data
```

**Lazy loading:** a category is read from disk the first time you ask for it, then
cached. Call `load_all()` up front (loading screen) if you want to avoid the first-
access read during gameplay (e.g. mid-battle).

---

## EquipmentEffects — an item's effects

Items name their effects in a per-type field: weapons `weapon_effect`, armor
`armor_effects`, accessories `accessory_effects` (a name or list of names).
`EquipmentEffects` looks those names up in the matching effects collection.

```gdscript
# By item key (fetches the item for you):
var effects := EquipmentEffects.for_item_key("boots", "Test Boots")
# [ { "effect_name": "defense_boost", "description": "...", "value": 0.1 } ]

# If you already hold the item Dictionary:
var item := DbLoader.get_item("swords", "Test Sword") as Dictionary
var sword_effects := EquipmentEffects.for_item("swords", item)

# Item + its effects bundled together (deep copy, under "_effects"):
var bundle := EquipmentEffects.with_effects("swords", "Test Sword")
# bundle["_effects"] -> [ ... ]

# One effect directly by name:
var fx := EquipmentEffects.get_effect("swords", "keen_edge")
```

Using the result anywhere — UI, attributes, damage:
```gdscript
for fx in EquipmentEffects.for_item_key("swords", weapon_name):
    tooltip_text += "%s\n" % fx["description"]   # UI
    bonus += float(fx.get("value", 0.0))         # stat / damage math
```

---

## ConditionChecker — effects that only apply sometimes

An effect may carry an optional `"condition"`. Build a `context` Dictionary
describing the situation, and ask for only the effects that currently apply. The
context keys are standardized in `BattleContext` — see
[guide.to.battle.context.md](guide.to.battle.context.md) for the full key list.

```gdscript
var context := {
    "wearer_hp_pct": 0.25,
    "target_type": "undead",
    "statuses": ["Poison"],
}
var active := EquipmentEffects.active_for_item_key("swords", weapon_name, context)
# only effects whose condition passes (effects with no condition always pass)
```

Condition shapes in the effect JSON (all optional):
```json
"condition": { "key": "wearer_hp_pct", "op": "<", "value": 0.3 }
"condition": { "key": "target_type", "op": "==", "value": "undead" }
"condition": { "key": "statuses", "op": "has", "value": "Poison" }
"condition": [
    { "key": "wearer_hp_pct", "op": "<", "value": 0.3 },
    { "key": "target_type", "op": "==", "value": "undead" }
]
```
A list means **all** clauses must pass (AND). Ops: `==`, `!=`, `<`, `<=`, `>`,
`>=`, `in` (actual is one of value), `has` (actual array contains value). Extend
by adding ops in `condition_checker.gd` or new keys to your `context`.

---

## Adding content (just edit JSON)

Each leaf folder has a `JSON/` subfolder. Drop a `.json` file in — no code changes.

**Items** (weapons, armor, accessories, quest/usable/consumable): one file per
item. The item must include the category's key field (that becomes its lookup key):

| Category | key field | effects field |
|---|---|---|
| swords / axes / bows / daggers / greatswords / knives / staves | `<type>_name` (e.g. `sword_name`) | `weapon_effect` |
| helmets | `helmets_name` | `armor_effects` |
| chests | `chest_name` | `armor_effects` |
| boots / bottoms / gloves | `<slot>_name` | `armor_effects` |
| l_rings / r_rings / necklaces | `<slot>_name` (e.g. `necklace_name`) | `accessory_effects` |
| quest_items | `name` | — |
| consumables | `consumable_name` | — |
| defensive_items / offensive_items / support_items | `item_name` | — |

Example weapon (`equipment/weapons/weapon_types/sword/JSON/flame_brand.json`):
```json
{
    "sword_name": "Flame Brand",
    "description": "A blade wreathed in fire.",
    "weapon_class": { "one_handed": true, "two_handed": false },
    "weapon_effect": ["keen_edge"]
}
```

**Effects** (`*_effects` folders): one collection file holding an array under the
folder's root key, each entry keyed by `effect_name`. Add an object to the array:
```json
{
    "sword_effects": [
        { "effect_name": "keen_edge", "description": "Increases crit chance.", "value": 0.15 },
        { "effect_name": "low_hp_rage", "description": "+25% damage at low HP.", "value": 0.25,
          "condition": { "key": "wearer_hp_pct", "op": "<", "value": 0.3 } }
    ]
}
```

JSON numbers parse as `float` in Godot — cast with `int(...)` if you need an int.

---

## Notes

- `res://` is the **repo root**, so data paths are `res://JRPG_Code/JRPG_Script/data/...`.
- If a new `class_name` script (e.g. a helper) shows "not declared", let Godot
  rescan (focus the editor, or Project ▸ Reload Current Project).
- Adding a brand-new category: add its loader `.gd` + `JSON/` folder, register it
  in `DbLoader._ready()`, and (if it grants effects) add a row to
  `EquipmentEffects.LINKS`.
