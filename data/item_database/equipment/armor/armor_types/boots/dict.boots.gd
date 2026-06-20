# Boots loader. Each .json file in JSON/ is one pair of boots, keyed by its "boots_name".
# To add boots: drop a new .json file in JSON/ — no code changes needed.

const JSON_DIR := "res://JRPG_Code/JRPG_Script/data/item_database/equipment/armor/armor_types/boots/JSON/"
const KEY_FIELD := "boots_name"

static func get_all() -> Dictionary:
	return JsonDB.load_dir(JSON_DIR, KEY_FIELD)
