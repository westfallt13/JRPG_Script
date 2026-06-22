# Combatant — Guide

A **`Combatant`** is one entity's *live* state — the object the rest of the game
hangs off. The data layer can load attributes, HP/MP, equipment, and statuses, but
until now nothing represented *"a level-12 hero wearing the Test Sword who is
currently Poisoned."* That entity is this class (Plan, Phase 2 — the keystone).

`class_name Combatant extends RefCounted` — reference-counted, so it frees itself;
no `queue_free`. It's a global class, available everywhere by name.

---

## Templates vs. live state

This is the line the framework draws (Plan, Phase 1/2 split):

- **Templates** = the JSON categories (`attributes`, `health_and_mana`, …). These are
  shared **defaults**, owned by `DbLoader`. Never mutate them.
- **Live state** = a `Combatant`. `seed_from_templates()` copies the defaults in once;
  everything after that is *this character's own* values, free to change in play.

So two heroes start from the same `attributes` template but diverge the moment one
levels up or takes damage.

---

## Building one

```gdscript
# From the Phase 1 templates (uses the global DbLoader autoload — game runtime):
var hero := Combatant.from_templates("Aria", 12)   # name, level
# hero.base_attributes == { "strength": 10, ... }, HP/MP seeded from health_and_mana

# Or build blank and set state yourself (no DB needed — handy in tests):
var dummy := Combatant.new("Dummy", 1)
dummy.base_attributes = { "strength": 8 }
dummy.max_health = 40
dummy.current_health = 40
```

`seed_from_templates(loader)` takes an optional `DbLoader` instance. Game code omits
it (uses the autoload); the editor test injects one, because the autoload isn't live
in the editor.

---

## Equipment

Each slot stores its item's **category and key together**, because effects are
resolved per category — a `"weapon"` slot could hold a sword *or* an axe *or* a bow,
and `EquipmentEffects` needs to know which collection to read.

```gdscript
hero.equip("weapon", "swords", "Test Sword")   # slot, DbLoader category, item key
hero.equip("boots",  "boots",  "Test Boots")

hero.is_equipped("weapon")   # true
hero.equipped("weapon")      # { "category": "swords", "key": "Test Sword" }
hero.unequip("boots")
```

Slots: `weapon`, `helmet`, `chest`, `bottoms`, `gloves`, `boots`, `l_ring`, `r_ring`,
`necklace` (see `Combatant.SLOTS`). `equip` returns `false` for an unknown slot. It
doesn't check the item exists (that needs the DB) — call `validate()` at runtime for
that:

```gdscript
var bad := hero.validate()   # [] when every equipped item resolves; else ["slot: cat/key", …]
```

---

## Statuses

```gdscript
hero.add_status("Poison")      # dedups
hero.has_status("Poison")      # true
hero.remove_status("Poison")
# hero.statuses is the Array[String] of status_condition names
```

---

## Leveling

`level` and `xp` are fields; the [`Leveling`](../stats/level_ups/guide.to.level.ups.md)
system grows them from a curve:

```gdscript
Leveling.grant_xp(hero, 300)   # add XP, apply every level-up crossed -> [2, 3]
```

`gain_level(gains)` is the per-level mutation it drives: `max_health`/`max_mana` grow
the pool (and `current_*` rises with it), any other key grows that **base** attribute —
so equipment modifiers still stack on top via `total_stat`.

---

## Derived reads

```gdscript
hero.hp_pct()               # 0.0..1.0, safe at max_health == 0
hero.mp_pct()
hero.base_stat("strength")  # this combatant's base value (int)

# Gear-aware (resolve active equipment effects through EffectResolver):
hero.total_stat("crit_chance")          # base attr (0 if none) + active gear mods
hero.derived_stat("damage", base_dmg)   # apply gear mods to a base from elsewhere
hero.equipment_modifiers()              # { stat: {add, mult}, ... } from active gear
```

`total_stat(stat)` folds equipment onto the combatant's own base attribute as
`(base + Σadd) × (1 + Σmult)`. With the Test Sword equipped,
`total_stat("crit_chance")` is `0.15` (keen_edge, a flat `add`) and `0` with no
weapon. For derived stats whose base lives elsewhere — like per-attack `damage` —
use `derived_stat(stat, base)`: at <30% HP the Test Sword's `low_hp_rage` (a `mult`)
turns a base 100 into 125, and leaves it at 100 otherwise. See
[guide.to.effect.resolver.md](../db_loader/guide.to.effect.resolver.md) for the
effect schema and aggregation rules.

---

## build_context() — the one place wearer keys are built

`build_context()` turns the combatant into a context `Dictionary` for
`ConditionChecker` / `EquipmentEffects`. It goes through `BattleContext`, so it emits
the canonical wearer keys (`wearer_hp_pct`, `wearer_statuses`, …). Because this is the
**single** builder, the data side and code side can't drift on spelling — this closes
the old `statuses` vs `wearer_statuses` footgun (Plan fix-list #6).

```gdscript
var ctx := hero.build_context()
# { "wearer_hp": 25, "wearer_max_hp": 100, "wearer_hp_pct": 0.25,
#   "wearer_level": 12, "wearer_statuses": ["Poison"],
#   "wearer_mp": ..., "wearer_max_mp": ..., "wearer_mp_pct": ... }
```

It builds the **wearer** side only. Battle code adds the target/action side on top via
`BattleContext` when there's an opponent.

---

## active_equipment_effects() — the integration payoff

Gathers every equipped item's effects and keeps only the ones whose condition passes
for this combatant *right now* (using `build_context()` unless you pass your own):

```gdscript
hero.current_health = hero.max_health
hero.active_equipment_effects()
# Test Sword at full HP -> [ keen_edge ]            (low_hp_rage's condition fails)

hero.current_health = 25                            # < 30% HP
hero.active_equipment_effects()
# -> [ keen_edge, low_hp_rage ]                     (condition now passes)
```

That second result is the whole Phase 1↔2 stack working end-to-end: a live entity →
its context → resolved, condition-filtered gear effects. (Runtime path — uses the
global `DbLoader`/`EquipmentEffects`.)

---

## Verifying

- **`tools/combatant_test.gd`** — `EditorScript` (Ctrl+Shift+X). Tests the
  autoload-free surface: seeding (injected loader), equip, statuses, `hp_pct`,
  `build_context` keys, and `fold_stat`. Prints PASS/FAIL.
- **`node_2dtestdb.gd`** (run the project, F5) — the live path the editor can't reach:
  `from_templates`, `active_equipment_effects` with conditions, `total_stat`,
  `validate`.

---

## What's next

- **Phase 3 (done)** gave effects `kind`/`target`/`op`; `total_stat` / `derived_stat`
  now fold them through [`EffectResolver`](../db_loader/guide.to.effect.resolver.md).
- **Phase 4** (leveling) grows a combatant's attributes/HP from data.
- **Phase 5** wires two combatants into a turn loop.
