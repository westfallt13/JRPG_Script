# Quest-item loader. Each .json file in JSON/ is one quest item, keyed by its "name".
# To add a quest item: drop a new .json file in JSON/ — no code changes needed.

const JSON_DIR := "res://JRPG_Code/JRPG_Script/data/item_database/quest_items/JSON/"
const KEY_FIELD := "name"

static func get_all() -> Dictionary:
	return JsonDB.load_dir(JSON_DIR, KEY_FIELD)
