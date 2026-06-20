# Greatsword-effects loader. One JSON file holding an array under "greatsword_effects";
# each entry is keyed by its "effect_name".
# To add an effect: add an object to the array in JSON/greatsword_effects.json.
@tool
extends EditorScript

const JSON_FILE := "res://JRPG_Code/JRPG_Script/data/item_database/equipment/weapons/weapon_effects/greatswords/JSON/greatsword_effects.json"
const ROOT_KEY := "greatsword_effects"
const KEY_FIELD := "effect_name"

static func get_all() -> Dictionary:
	return JsonDB.load_collection(JSON_FILE, ROOT_KEY, KEY_FIELD)
