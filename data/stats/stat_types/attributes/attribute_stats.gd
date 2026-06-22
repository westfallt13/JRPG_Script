# Attributes loader. One JSON file holding an array under "attributes"; each entry
# is keyed by its "attribute_name". These are TEMPLATE DEFAULTS (e.g. strength 10) —
# a character's live per-instance values belong on the Combatant (Plan, Phase 2),
# not here.
# To add an attribute: add an object to the array in JSON/attributes.json.

const JSON_FILE := "res://JRPG_Code/JRPG_Script/data/stats/stat_types/attributes/JSON/attributes.json"
const ROOT_KEY := "attributes"
const KEY_FIELD := "attribute_name"

static func get_all() -> Dictionary:
	return JsonDB.load_collection(JSON_FILE, ROOT_KEY, KEY_FIELD)
