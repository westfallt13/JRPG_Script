# Gloves loader. Each .json file in JSON/ is one pair of gloves, keyed by its "gloves_name".
# To add gloves: drop a new .json file in JSON/ — no code changes needed.

const JSON_DIR := "res://JRPG_Code/JRPG_Script/data/item_database/equipment/armor/armor_types/gloves/JSON/"
const KEY_FIELD := "gloves_name"

static func get_all() -> Dictionary:
	return JsonDB.load_dir(JSON_DIR, KEY_FIELD)
