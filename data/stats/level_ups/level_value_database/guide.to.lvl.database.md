# Level Value Database — Guide

The **data** behind leveling: a *level curve* — XP thresholds and the stat gains each
level grants. The logic that consumes it is [`Leveling`](../guide.to.level.ups.md).

## The default curve

[JSON/default_curve.json](JSON/default_curve.json) is the framework's public default,
loaded as the `DbLoader` category `"level_curve"`:

```json
{
    "level_curve": [
        { "level": 1, "xp_to_reach": 0,   "gains": {} },
        { "level": 2, "xp_to_reach": 100, "gains": { "max_health": 10, "max_mana": 5, "strength": 2, "vitality": 1 } }
    ]
}
```

| Field | Meaning |
|---|---|
| `level` | The level number. |
| `xp_to_reach` | **Total** accumulated XP to *be* this level (level 1 is `0`). Must increase with level. |
| `gains` | Stat deltas applied when the combatant **reaches** this level. Keys are attribute names (`strength`, …) and the pools `max_health` / `max_mana`. Level 1 has none (starting state). |

The loader keys the curve by level as an **int** (so `curve[2]` works — `JsonDB.index_by`
would key by the JSON number `2.0` and miss). To retune progression, just edit the
numbers in `JSON/default_curve.json`.

## Per-character / per-class curves (private)

The `level_curves/` folder is **gitignored** — that's where a game's own per-character
or per-class curves live (a mage that grows `intelligence`, a warrior that grows
`strength`). They never need to go through `DbLoader`: load one however you like and
hand it straight to `Leveling`:

```gdscript
Leveling.grant_xp(mage, xp, my_mage_curve)   # any curve dict, same shape as above
```

So the framework ships one sensible default; your real balancing stays out of the
public repo.
