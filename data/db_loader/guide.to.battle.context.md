# Battle Context — Master Guide

A **context** is a plain `Dictionary` describing the current situation (who's
wearing the gear, who's being hit, the action, the turn). `ConditionChecker`
reads it to decide whether an effect's `condition` applies; your calc code reads
it to do math. [`BattleContext`](battle_context.gd) defines the shared key names
so the JSON side and the code side never drift.

```
effect JSON  "condition": { "key": "wearer_hp_pct", "op": "<", "value": 0.3 }
                                    │ same string
GDScript     BattleContext.WEARER_HP_PCT == "wearer_hp_pct"
                                    │ same key in the dict
context      { "wearer_hp_pct": 0.25, ... }   ← built by BattleContext
```

`BattleContext` is a `class_name` global — available everywhere, no autoload needed.

---

## All context keys

`(derived)` keys are computed for you by the builder from HP/MP + max.

### Wearer — the entity whose equipment/effects are being evaluated
| Constant | String name | Type | Meaning |
|---|---|---|---|
| `BattleContext.WEARER_HP` | `wearer_hp` | int | current HP |
| `BattleContext.WEARER_MAX_HP` | `wearer_max_hp` | int | max HP |
| `BattleContext.WEARER_HP_PCT` | `wearer_hp_pct` | float 0–1 | HP fraction *(derived)* |
| `BattleContext.WEARER_MP` | `wearer_mp` | int | current MP |
| `BattleContext.WEARER_MAX_MP` | `wearer_max_mp` | int | max MP |
| `BattleContext.WEARER_MP_PCT` | `wearer_mp_pct` | float 0–1 | MP fraction *(derived)* |
| `BattleContext.WEARER_LEVEL` | `wearer_level` | int | level |
| `BattleContext.WEARER_STATUSES` | `wearer_statuses` | Array[String] | active status names |

### Target — the entity being acted upon
| Constant | String name | Type | Meaning |
|---|---|---|---|
| `BattleContext.TARGET_TYPE` | `target_type` | String | e.g. `"undead"`, `"beast"` |
| `BattleContext.TARGET_HP` | `target_hp` | int | current HP |
| `BattleContext.TARGET_MAX_HP` | `target_max_hp` | int | max HP |
| `BattleContext.TARGET_HP_PCT` | `target_hp_pct` | float 0–1 | HP fraction *(derived)* |
| `BattleContext.TARGET_LEVEL` | `target_level` | int | level |
| `BattleContext.TARGET_STATUSES` | `target_statuses` | Array[String] | active status names |
| `BattleContext.TARGET_IS_BOSS` | `target_is_boss` | bool | boss flag |

### Action / battle-wide
| Constant | String name | Type | Meaning |
|---|---|---|---|
| `BattleContext.DAMAGE_TYPE` | `damage_type` | String | `"physical"` / `"magical"` |
| `BattleContext.ELEMENT` | `element` | String | `"fire"`, `"ice"`, … |
| `BattleContext.IS_CRIT` | `is_crit` | bool | hit was a critical |
| `BattleContext.TURN` | `turn` | int | current turn number |

---

## Building a context

**Fluent builder** (recommended — derives the `_pct` keys for you):
```gdscript
var ctx := BattleContext.new() \
    .set_wearer(current_hp, max_hp, level, ["Poison"]) \
    .set_target("undead", enemy_hp, enemy_max_hp) \
    .set_action("physical", "fire", false, turn_number) \
    .to_dict()
```
Each setter returns the builder so you can chain; call only the ones you need.
`.set_wearer_mp(mp, max_mp)` adds the MP keys. `.put(key, value)` adds a custom
key. `.to_dict()` returns the finished Dictionary.

**Plain dictionary** (also fine — use the constants to avoid typos):
```gdscript
var ctx := {
    BattleContext.WEARER_HP_PCT: BattleContext.pct(current_hp, max_hp),
    BattleContext.TARGET_TYPE: "undead",
}
```

---

## Reading a context in calc code

Use the typed getters — they return a default (never crash) if a key is missing
or the wrong type:
```gdscript
var hp_frac := BattleContext.num(ctx, BattleContext.WEARER_HP_PCT)   # float, 0.0 if absent
var dtype   := BattleContext.text(ctx, BattleContext.DAMAGE_TYPE)    # String, "" if absent
var crit    := BattleContext.flag(ctx, BattleContext.IS_CRIT)        # bool, false if absent
var statuses := BattleContext.list(ctx, BattleContext.TARGET_STATUSES) # Array, [] if absent
```

---

## Full round trip

```gdscript
# 1. Build the situation
var ctx := BattleContext.new() \
    .set_wearer(player.hp, player.max_hp) \
    .set_target("undead", enemy.hp, enemy.max_hp) \
    .set_action("physical", "fire", false, turn) \
    .to_dict()

# 2. Resolve only the effects that apply right now
var effects := EquipmentEffects.active_for_item_key("swords", equipped_sword, ctx)

# 3. Apply them — fold by each effect's target/op with EffectResolver
for fx in effects:
    log_line(fx["description"])
final_damage = EffectResolver.derived(base_damage, "damage", effects)
```

The matching effect JSON (in `sword_effects.json`):
```json
{ "effect_name": "low_hp_rage", "description": "+25% damage below 30% HP.",
  "value": 0.25, "condition": { "key": "wearer_hp_pct", "op": "<", "value": 0.3 } }
```

See [guide.to.db.loader.md](guide.to.db.loader.md) for the condition operators
(`== != < <= > >= in has`) and combining clauses (a list = AND).

---

## Extending the vocabulary

1. Add a constant to `battle_context.gd` (e.g. `const WEATHER := "weather"`).
2. Set it when building (`.put(BattleContext.WEATHER, "rain")`, or add a setter).
3. Reference it from effect conditions: `{ "key": "weather", "op": "==", "value": "rain" }`.

No other file changes — `ConditionChecker` reads whatever key the condition names.
