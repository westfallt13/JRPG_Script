# Accessory-effects loader. One JSON file holding an array under "accessory_effects";
# each entry is keyed by its "effect_name".
# To add an effect: add an object to the array in accessory_effects.json.
@tool
extends EditorScript

const JSON_FILE := "res://JRPG_Code/JRPG_Script/data/item_database/equipment/accessories/accessory_effects/JSON/accessory_effects.json"
const ROOT_KEY := "accessory_effects"
const KEY_FIELD := "effect_name"

static func get_all() -> Dictionary:
	return JsonDB.load_collection(JSON_FILE, ROOT_KEY, KEY_FIELD)
	
func _run():
	print("Here is your accessory effects.", KEY_FIELD)

## Figure out a way to link boot items in JSON object to their effects in armor_effects.json. Maybe an "armor_effects" field in the boots JSON, which is a list of effect names? Then we can look up those names in the armor_effects collection to get/apply the actual effect data.
