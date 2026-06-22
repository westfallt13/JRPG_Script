# Health & mana loader. One JSON file holding an array under "health_and_mana";
# each entry is keyed by its "stat_name". These are TEMPLATE DEFAULTS for the HP/MP
# pools; a character's live current/max values belong on the Combatant (Plan,
# Phase 2), not here.
# To add a pool stat: add an object to the array in JSON/health_and_mana.json.

const JSON_FILE := "res://JRPG_Code/JRPG_Script/data/stats/stat_types/health_and_mana/JSON/health_and_mana.json"
const ROOT_KEY := "health_and_mana"
const KEY_FIELD := "stat_name"

static func get_all() -> Dictionary:
	return JsonDB.load_collection(JSON_FILE, ROOT_KEY, KEY_FIELD)
