# Chest loader. Each .json file in JSON/ is one chest piece, keyed by its "chest_name".
# To add a chest piece: drop a new .json file in JSON/ — no code changes needed.

const JSON_DIR := "res://JRPG_Code/JRPG_Script/data/item_database/equipment/armor/armor_types/chests/JSON/"
const KEY_FIELD := "chest_name"

static func get_all() -> Dictionary:
	return JsonDB.load_dir(JSON_DIR, KEY_FIELD)
