# Staff loader. Each .json file in JSON/ is one staff, keyed by its "staff_name".
# To add a staff: drop a new .json file in JSON/ — no code changes needed.

const JSON_DIR := "res://JRPG_Code/JRPG_Script/data/item_database/equipment/weapons/weapon_types/staff/JSON/"
const KEY_FIELD := "staff_name"

static func get_all() -> Dictionary:
	return JsonDB.load_dir(JSON_DIR, KEY_FIELD)
