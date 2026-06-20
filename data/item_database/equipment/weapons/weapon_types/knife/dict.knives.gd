# Knife loader. Each .json file in JSON/ is one knife, keyed by its "knife_name".
# To add a knife: drop a new .json file in JSON/ — no code changes needed.

const JSON_DIR := "res://JRPG_Code/JRPG_Script/data/item_database/equipment/weapons/weapon_types/knife/JSON/"
const KEY_FIELD := "knife_name"

static func get_all() -> Dictionary:
	return JsonDB.load_dir(JSON_DIR, KEY_FIELD)
