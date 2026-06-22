class_name Leveling

# XP & level-up logic (Plan, Phase 4). The NUMBERS live in a level curve (JSON,
# loaded as the "level_curve" DbLoader category); the MATH — thresholds, how many
# levels a chunk of XP crosses, applying gains — lives here.
#
# A curve is { level:int -> { "level", "xp_to_reach": <total XP>, "gains": {stat:delta} } }.
# `xp_to_reach` is the TOTAL accumulated XP to BE that level (level 1 == 0). `gains`
# is applied when the combatant REACHES that level. Pass your own `curve` (e.g. a
# private per-character curve) or omit it to use the default "level_curve" category.
#
# All methods static: call Leveling.grant_xp(combatant, 300).

# Add XP and apply every level-up it crosses. Mutates the combatant (xp, level, and
# the gains). Returns the list of levels gained, e.g. [2, 3] (empty if none).
static func grant_xp(combatant, amount: int, curve: Dictionary = {}) -> Array:
	var c := curve if not curve.is_empty() else _default_curve()
	combatant.xp += max(0, amount)
	var gained: Array = []
	while c.has(combatant.level + 1) and combatant.xp >= int(c[combatant.level + 1].get("xp_to_reach", 0)):
		var next_level: int = combatant.level + 1
		combatant.gain_level(c[next_level].get("gains", {}))
		gained.append(next_level)
	return gained


# Advance one level (apply the next level's gains), ignoring XP. The primitive
# grant_xp builds on; handy for scripted/debug level-ups. Returns false at max level.
static func level_up(combatant, curve: Dictionary = {}) -> bool:
	var c := curve if not curve.is_empty() else _default_curve()
	var next_level: int = combatant.level + 1
	if not c.has(next_level):
		return false
	combatant.gain_level(c[next_level].get("gains", {}))
	return true


# The highest level whose XP threshold is met by `xp` (assumes thresholds increase
# with level). Never below 1.
static func level_for_xp(xp: int, curve: Dictionary = {}) -> int:
	var c := curve if not curve.is_empty() else _default_curve()
	var best := 1
	for level in c:
		if xp >= int(c[level].get("xp_to_reach", 0)):
			best = max(best, int(level))
	return best


# Total accumulated XP needed to reach `level` (0 if the curve has no such level).
static func xp_to_reach(level: int, curve: Dictionary = {}) -> int:
	var c := curve if not curve.is_empty() else _default_curve()
	return int(c.get(level, {}).get("xp_to_reach", 0))


# Highest level defined in the curve.
static func max_level(curve: Dictionary = {}) -> int:
	var c := curve if not curve.is_empty() else _default_curve()
	var top := 1
	for level in c:
		top = max(top, int(level))
	return top


# The default curve from DbLoader. Runtime only (the autoload isn't live in the
# editor) — pass an explicit `curve` to the functions above to work without it.
static func _default_curve() -> Dictionary:
	return DbLoader.get_category("level_curve")
