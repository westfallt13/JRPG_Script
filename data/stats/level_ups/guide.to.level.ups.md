# Leveling — Guide

`class_name Leveling` (in [level_ups.gd](level_ups.gd)) is the XP & level-up logic
(Plan, Phase 4). The **numbers** live in a level curve (JSON; see
[level_value_database/guide.to.lvl.database.md](level_value_database/guide.to.lvl.database.md));
the **math** — thresholds, how many levels a chunk of XP crosses, applying the gains —
lives here. All static: call `Leveling.grant_xp(...)`, no instance.

---

## The one call you usually want

```gdscript
var levels := Leveling.grant_xp(hero, 300)   # add XP, apply every level-up it crosses
# -> [2, 3]  (the levels just gained; [] if none)
```

`grant_xp` adds to `hero.xp`, then keeps levelling while the next level's threshold is
met — so a single big reward can cross several levels at once. Each level-up calls
`hero.gain_level(gains)`, which grows the combatant's base attributes and HP/MP pools.

Omit the curve to use the default (`DbLoader` category `"level_curve"`), or pass your
own — e.g. a private per-character curve:

```gdscript
Leveling.grant_xp(mage, 300, mage_curve)
```

---

## The rest of the API

```gdscript
Leveling.level_up(c)            # advance ONE level, ignoring XP (scripted/debug). false at max.
Leveling.level_for_xp(420)      # the level a given total XP corresponds to
Leveling.xp_to_reach(4)         # total XP needed to be level 4
Leveling.max_level()            # highest level the curve defines
```

Each takes an optional trailing `curve` argument, same as `grant_xp`.

---

## What a level-up does to a Combatant

`gain_level(gains)` advances `level` by 1 and applies the `gains` dict:

- `"max_health"` / `"max_mana"` grow the pool, and `current_*` rises by the same
  delta — the pool expands without a surprise full-heal or chip damage. (Prefer a
  classic heal-on-level? Set `current_health = max_health` after.)
- any other key (`"strength"`, `"vitality"`, …) grows that **base** attribute. Because
  it's the base, equipment modifiers (Phase 3) still apply on top via `total_stat`.

XP and level only stay in step if you go through `grant_xp`; `gain_level` is the raw
mutation it builds on — call it directly only for tests/scripted bumps.

---

## Verifying

Leveling is pure logic + Combatant mutation — no `DbLoader` needed when you pass a
curve — so it's fully covered in `tools/combatant_test.gd` (Ctrl+Shift+X). The live
default-curve path also runs in `node_2dtestdb.gd` (F5).
