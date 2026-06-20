# Bottoms loader. Each .json file in JSON/ is one bottoms item, keyed by its "bottoms_name".
# To add bottoms: drop a new .json file in JSON/ — no code changes needed.

const JSON_DIR := "res://JRPG_Code/JRPG_Script/data/item_database/equipment/armor/armor_types/bottoms/JSON/"
const KEY_FIELD := "bottoms_name"

static func get_all() -> Dictionary:
	return JsonDB.load_dir(JSON_DIR, KEY_FIELD)
