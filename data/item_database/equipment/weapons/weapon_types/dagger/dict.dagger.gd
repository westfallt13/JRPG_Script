# Dagger loader. Each .json file in JSON/ is one dagger, keyed by its "dagger_name".
# To add a dagger: drop a new .json file in JSON/ — no code changes needed.

const JSON_DIR := "res://JRPG_Code/JRPG_Script/data/item_database/equipment/weapons/weapon_types/dagger/JSON/"
const KEY_FIELD := "dagger_name"

static func get_all() -> Dictionary:
	return JsonDB.load_dir(JSON_DIR, KEY_FIELD)
