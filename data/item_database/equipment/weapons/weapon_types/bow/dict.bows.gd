# Bow loader. Each .json file in JSON/ is one bow, keyed by its "bow_name".
# To add a bow: drop a new .json file in JSON/ — no code changes needed.

const JSON_DIR := "res://JRPG_Code/JRPG_Script/data/item_database/equipment/weapons/weapon_types/bow/JSON/"
const KEY_FIELD := "bow_name"

static func get_all() -> Dictionary:
	return JsonDB.load_dir(JSON_DIR, KEY_FIELD)
