# Necklace loader. Each .json file in JSON/ is one necklace, keyed by its "necklace_name".
# To add a necklace: drop a new .json file in JSON/ — no code changes needed.
# (Change KEY_FIELD if you name the field differently in your JSON.)

const JSON_DIR := "res://JRPG_Code/JRPG_Script/data/item_database/equipment/accessories/necklace/JSON/"
const KEY_FIELD := "necklace_name"

static func get_all() -> Dictionary:
	return JsonDB.load_dir(JSON_DIR, KEY_FIELD)
