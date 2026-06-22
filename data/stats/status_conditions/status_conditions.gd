# Status-conditions loader. One JSON file holding an array under "status_conditions";
# each entry is keyed by its "status_name".
# To add a condition: add an object to the array in JSON/status_conditions.json.

const JSON_FILE := "res://JRPG_Code/JRPG_Script/data/stats/status_conditions/JSON/status_conditions.json"
const ROOT_KEY := "status_conditions"
const KEY_FIELD := "status_name"

static func get_all() -> Dictionary:
	return JsonDB.load_collection(JSON_FILE, ROOT_KEY, KEY_FIELD)
