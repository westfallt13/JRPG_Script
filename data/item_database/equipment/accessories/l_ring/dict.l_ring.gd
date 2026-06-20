# Left-ring loader. Each .json file in JSON/ is one ring, keyed by its "l_ring_name".
# To add a left ring: drop a new .json file in JSON/ — no code changes needed.
# (Change KEY_FIELD if you name the field differently in your JSON.)

const JSON_DIR := "res://JRPG_Code/JRPG_Script/data/item_database/equipment/accessories/l_ring/JSON/"
const KEY_FIELD := "l_ring_name"

static func get_all() -> Dictionary:
	return JsonDB.load_dir(JSON_DIR, KEY_FIELD)
