# Enemy-abilities loader. One JSON file holding an array under "enemy_abilities";
# each entry is keyed by its "enemy_ability_name".
# To add an ability: add an object to the array in JSON/enemy_abilities.json.

const JSON_FILE := "res://JRPG_Code/JRPG_Script/data/stats/ability_and_stability/ability_types/enemy_abilities/JSON/enemy_abilities.json"
const ROOT_KEY := "enemy_abilities"
const KEY_FIELD := "enemy_ability_name"

static func get_all() -> Dictionary:
	return JsonDB.load_collection(JSON_FILE, ROOT_KEY, KEY_FIELD)
