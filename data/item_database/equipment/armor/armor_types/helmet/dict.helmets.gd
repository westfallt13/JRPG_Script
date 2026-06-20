# Helmet loader. Each .json file in JSON/ is one helmet, keyed by its "helmets_name".
# To add a helmet: drop a new .json file in JSON/ — no code changes needed.

const JSON_DIR := "res://JRPG_Code/JRPG_Script/data/item_database/equipment/armor/armor_types/helmet/JSON/"
const KEY_FIELD := "helmets_name"

static func get_all() -> Dictionary:
	return JsonDB.load_dir(JSON_DIR, KEY_FIELD)
