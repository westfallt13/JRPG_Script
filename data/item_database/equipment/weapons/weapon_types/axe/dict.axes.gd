# Axe loader. Each .json file in JSON/ is one axe, keyed by its "axe_name".
# To add an axe: drop a new .json file in JSON/ — no code changes needed.

const JSON_DIR := "res://JRPG_Code/JRPG_Script/data/item_database/equipment/weapons/weapon_types/axe/JSON/"
const KEY_FIELD := "axe_name"

static func get_all() -> Dictionary:
	return JsonDB.load_dir(JSON_DIR, KEY_FIELD)
