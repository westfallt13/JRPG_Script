# Magic-abilities loader. One JSON file holding an array under "magic_abilities";
# each entry is keyed by its "magic_ability_name".
# To add an ability: add an object to the array in JSON/magic_abilities.json.

const JSON_FILE := "res://JRPG_Code/JRPG_Script/data/stats/ability_and_stability/ability_types/magic_abilities/JSON/magic_abilities.json"
const ROOT_KEY := "magic_abilities"
const KEY_FIELD := "magic_ability_name"

static func get_all() -> Dictionary:
	return JsonDB.load_collection(JSON_FILE, ROOT_KEY, KEY_FIELD)
