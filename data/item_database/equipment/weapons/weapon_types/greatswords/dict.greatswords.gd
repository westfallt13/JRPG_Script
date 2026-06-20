# Greatsword loader. Each .json file in JSON/ is one greatsword, keyed by its "greatsword_name".
# To add a greatsword: drop a new .json file in JSON/ — no code changes needed.

const JSON_DIR := "res://JRPG_Code/JRPG_Script/data/item_database/equipment/weapons/weapon_types/greatswords/JSON/"
const KEY_FIELD := "greatsword_name"

static func get_all() -> Dictionary:
	return JsonDB.load_dir(JSON_DIR, KEY_FIELD)
