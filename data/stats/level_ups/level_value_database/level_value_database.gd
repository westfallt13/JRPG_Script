# Level-curve loader. One JSON file holding an array under "level_curve"; each entry
# is one level: { "level": N, "xp_to_reach": <total XP>, "gains": { stat: delta } }.
#
# Returns a Dictionary keyed by the level number as an INT (not via JsonDB.index_by,
# which would key by the raw JSON number — a float — so curve[2] would miss curve[2.0]).
#
# This is the framework's PUBLIC default curve. A game's private per-character curves
# live in the gitignored level_curves/ folder and can be passed to Leveling.* directly.
# To edit progression: change the numbers in JSON/default_curve.json.

const JSON_FILE := "res://JRPG_Code/JRPG_Script/data/stats/level_ups/level_value_database/JSON/default_curve.json"
const ROOT_KEY := "level_curve"

static func get_all() -> Dictionary:
	var parsed = JsonDB.read_json(JSON_FILE)
	var out := {}
	if not (parsed is Dictionary):
		return out
	for row in parsed.get(ROOT_KEY, []):
		if row is Dictionary and row.has("level"):
			out[int(row["level"])] = row
		else:
			push_warning("level_value_database: row missing 'level', skipped")
	return out
