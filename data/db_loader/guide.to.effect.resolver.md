# Effect Resolver — Guide

`EquipmentEffects` + `ConditionChecker` answer *"which effects apply right now?"*.
[`EffectResolver`](effect_resolver.gd) answers the next question: *"what do they do
to the numbers?"* It folds a list of resolved effects into per-stat modifiers (Plan,
Phase 3). `class_name EffectResolver`, all static — no instance, no autoload.

---

## The effect schema

An effect declares its intent alongside its `value`:

```json
{ "effect_name": "keen_edge", "description": "Increases critical hit chance.",
  "kind": "stat_mod", "target": "crit_chance", "op": "add", "value": 0.15 }
```

| Field | Meaning |
|---|---|
| `kind` | What sort of effect. Only `"stat_mod"` is read by the resolver today; other/absent kinds are ignored, so the schema can grow. |
| `target` | The stat it modifies (`"crit_chance"`, `"defense"`, `"damage"`, …). Free-form — the consumer decides what each name means. |
| `op` | `"add"` (flat) or `"mult"` (percentage). |
| `value` | The amount (`0.15` = +0.15 flat, or +15% for a `mult`). |
| `condition` | *(optional)* the usual `ConditionChecker` clause — gates whether the effect is active. |

The three starter kinds (Plan, Phase 3):
- **flat add** — `keen_edge`: `crit_chance += 0.15`
- **percent mult** — `defense_boost`: `defense × 1.10`
- **conditional damage bonus** — `low_hp_rage`: `damage × 1.25`, only while `wearer_hp_pct < 0.3`

---

## Aggregation

Per `target` stat, `add` ops sum and `mult` ops sum, then:

```
final = (base + Σ add) × (1 + Σ mult)
```

`mult` stacks **additively**: two `+25%` mults give `+50%` (×1.5), not ×1.5625. The
resolver does **not** clamp — a value can exceed 1.0 or go negative; clamp at the
point you consume it if your game needs it.

---

## API

Feed it effects that are already condition-filtered — the output of
`EquipmentEffects.active_for_item*` or `Combatant.active_equipment_effects()`.

```gdscript
var fx := combatant.active_equipment_effects()       # [ {effect_name, kind, target, op, value}, ... ]

EffectResolver.aggregate(fx)
# { "crit_chance": {"add": 0.15, "mult": 0.0}, "damage": {"add": 0.0, "mult": 0.25} }

EffectResolver.modifier_for(fx, "crit_chance")       # { "add": 0.15, "mult": 0.0 }
EffectResolver.apply(0.0, {"add": 0.15, "mult": 0.0})# 0.15   ((base+add)*(1+mult))
EffectResolver.derived(100.0, "damage", fx)          # 125.0  (base 100, +25% mult)
```

You rarely call it directly — `Combatant` wraps it:

```gdscript
hero.total_stat("crit_chance")          # base attribute + gear mods
hero.derived_stat("damage", base_dmg)   # gear mods over a base from elsewhere
hero.equipment_modifiers()              # the aggregate dict, for tooltips / sheets
```

---

## Adding an effect kind

`stat_mod` covers add/mult stat changes. For something genuinely different (say a
`"grant_status"` kind), add a branch where the consumer reads it — `aggregate` already
ignores kinds it doesn't recognize, so existing data keeps working untouched.
