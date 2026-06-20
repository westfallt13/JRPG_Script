# Staff-effects loader. One JSON file holding an array under "staff_effects";
# each entry is keyed by its "effect_name".
# To add an effect: add an object to the array in JSON/staff_effects.json.

const JSON_FILE := "res://JRPG_Code/JRPG_Script/data/item_database/equipment/weapons/weapon_effects/staff/JSON/staff_effects.json"
const ROOT_KEY := "staff_effects"
const KEY_FIELD := "effect_name"

static func get_all() -> Dictionary:
	return JsonDB.load_collection(JSON_FILE, ROOT_KEY, KEY_FIELD)
