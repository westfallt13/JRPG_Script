# Dagger loader. Each .json file in JSON/ is one dagger, keyed by its "dagger_name".
# To add a dagger: drop a new .json file in JSON/ — no code changes needed.
@tool
extends EditorScript

const JSON_DIR := "res://JRPG_Code/JRPG_Script/data/item_database/equipment/weapons/weapon_types/dagger/JSON/"
const KEY_FIELD := "dagger_name"

static func get_all() -> Dictionary:
	return JsonDB.load_dir(JSON_DIR, KEY_FIELD)

## Figure out a way to link boot items in JSON object to their effects in armor_effects.json. Maybe an "armor_effects" field in the boots JSON, which is a list of effect names? Then we can look up those names in the armor_effects collection to get/apply the actual effect data.