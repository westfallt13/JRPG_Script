# Necklace loader. Each .json file in JSON/ is one necklace, keyed by its "necklace_name".
# To add a necklace: drop a new .json file in JSON/ — no code changes needed.
# (Change KEY_FIELD if you name the field differently in your JSON.)
@tool
extends EditorScript


const JSON_DIR := "res://JRPG_Code/JRPG_Script/data/item_database/equipment/accessories/necklace/JSON/"
const KEY_FIELD := "necklace_name"

static func get_all() -> Dictionary:
	return JsonDB.load_dir(JSON_DIR, KEY_FIELD)

## Figure out a way to link boot items in JSON object to their effects in armor_effects.json. Maybe an "armor_effects" field in the boots JSON, which is a list of effect names? Then we can look up those names in the armor_effects collection to get/apply the actual effect data.