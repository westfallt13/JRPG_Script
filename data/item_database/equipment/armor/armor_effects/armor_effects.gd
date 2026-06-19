extends Node

const ARMOR_EFFECTS_PATH := "res://data/item_database/equipment/armor/armor_effects/JSON/armor_effects.json"


# --- Generic, reusable JSON access ------------------------------------------

# Reads a .json file and returns the parsed value (Dictionary or Array).
# Returns null on any failure so callers can decide how to react.
func read_json(path: String):
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("read_json: cannot open %s" % path)
		return null
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed == null:
		push_warning("read_json: failed to parse %s" % path)
	return parsed


# — the keying primitive. This is the array→dictionary conversion, generalized. It doesn't know anything about armor effects — give it any list of objects and a field name, and it keys by that field. Reuse it for index_by(weapons, "weapon_name"), index_by(items, "item_id"), etc.

# index_by([{ "effect_name": "x", ... }], "effect_name") -> { "x": { ... } }
func index_by(rows: Array, key_field: String) -> Dictionary:
	var table := {}
	for row in rows:
		if row is Dictionary and row.has(key_field):
			table[row[key_field]] = row
		else:
			push_warning("index_by: row missing '%s', skipped" % key_field)
	return table


# --- Armor effects ----------------------------------------------------------

# Returns every armor effect keyed by its "effect_name". Each value is the full
# effect object, so all sub-fields (description, value, …) come along with it.
func get_armor_effects() -> Dictionary:
	var parsed = read_json(ARMOR_EFFECTS_PATH)
	if not parsed is Dictionary:
		return {}
	return index_by(parsed.get("armor_effects", []), "effect_name")
