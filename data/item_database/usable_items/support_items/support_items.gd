# Support-item loader. Each .json file in JSON/ is one item, keyed by its "item_name".
# To add a support item: drop a new .json file in JSON/ — no code changes needed.
# (Change KEY_FIELD if you name the field differently in your JSON.)

const JSON_DIR := "res://JRPG_Code/JRPG_Script/data/item_database/usable_items/support_items/JSON/"
const KEY_FIELD := "item_name"

static func get_all() -> Dictionary:
	return JsonDB.load_dir(JSON_DIR, KEY_FIELD)
