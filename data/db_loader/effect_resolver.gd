class_name EffectResolver

# Folds resolved effects into derived-stat modifiers (Plan, Phase 3).
#
# EquipmentEffects/ConditionChecker answer "WHICH effects apply right now?". This
# answers the next question: "what do they DO to the numbers?". An effect declares
# its intent in the JSON:
#   { "effect_name": "keen_edge", "kind": "stat_mod", "target": "crit_chance",
#     "op": "add", "value": 0.15 }
#
# Only "stat_mod" effects with a "target" participate; anything else (flavor text,
# future kinds) is ignored, so the schema can grow without breaking this.
#
# Two ops, aggregated per target stat:
#   "add"  — flat addition          (crit_chance += 0.15)
#   "mult" — percentage, ADDITIVE   (two +25% mults => +50%, i.e. x1.5; not x1.5625)
# and applied as:  final = (base + sum_of_adds) * (1.0 + sum_of_mults)
# `apply` does NOT clamp — a stat can exceed 1.0 or go negative; clamping is a
# game-balance decision for the system that consumes the number.
#
# Feed it the output of EquipmentEffects.active_for_item* / Combatant.active_equipment_effects
# (already condition-filtered). All methods static: call EffectResolver.aggregate(...).

const KIND_STAT_MOD := "stat_mod"
const OP_ADD  := "add"
const OP_MULT := "mult"


# A zero modifier — the identity for apply() ((base + 0) * (1 + 0) == base).
static func zero_mod() -> Dictionary:
	return {"add": 0.0, "mult": 0.0}


# Fold effects into per-target modifiers: { "crit_chance": {"add": 0.15, "mult": 0.0}, ... }.
# This is the "derived-stats dictionary" — the aggregated equipment contributions.
static func aggregate(effects: Array) -> Dictionary:
	var mods := {}
	for fx in effects:
		if not (fx is Dictionary):
			continue
		if fx.get("kind", "") != KIND_STAT_MOD:
			continue
		var target: String = fx.get("target", "")
		if target == "":
			continue
		if not mods.has(target):
			mods[target] = zero_mod()
		var value := float(fx.get("value", 0.0))
		match fx.get("op", OP_ADD):
			OP_MULT:
				mods[target]["mult"] += value
			_:  # OP_ADD and anything unrecognized -> treat as a flat add
				mods[target]["add"] += value
	return mods


# The aggregated { "add", "mult" } modifier for one stat (zero modifier if none).
static func modifier_for(effects: Array, stat: String) -> Dictionary:
	return aggregate(effects).get(stat, zero_mod())


# Apply a single modifier to a base value: (base + add) * (1 + mult).
static func apply(base: float, mod: Dictionary) -> float:
	return (base + float(mod.get("add", 0.0))) * (1.0 + float(mod.get("mult", 0.0)))


# Convenience: base value for `stat` with `effects`' contributions folded in.
static func derived(base: float, stat: String, effects: Array) -> float:
	return apply(base, modifier_for(effects, stat))
