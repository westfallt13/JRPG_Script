extends Node

# Weapons
var axes: Array[Dictionary] = []
var bows: Array[Dictionary] = []
var daggers: Array[Dictionary] = []
var greatswords: Array[Dictionary] = []
var knives: Array[Dictionary] = []
var staves: Array[Dictionary] = []
var swords: Array[Dictionary] = []

# Armor
var boots: Array[Dictionary] = []
var bottoms: Array[Dictionary] = []
var chests: Array[Dictionary] = []
var gloves: Array[Dictionary] = []
var helmets: Array[Dictionary] = []

# Accessories
var l_rings: Array[Dictionary] = []
var r_rings: Array[Dictionary] = []
var necklaces: Array[Dictionary] = []

# Other
var quest_items: Array[Dictionary] = []
var consumables: Array[Dictionary] = []
var offensive_items: Array[Dictionary] = []
var defensive_items: Array[Dictionary] = []
var support_items: Array[Dictionary] = []

const _BASE := "res://data/item_database/"

func _ready() -> void:
	axes        = _load_json_dir(_BASE + "equipment/weapons/weapon_types/axe/JSON/")
	bows        = _load_json_dir(_BASE + "equipment/weapons/weapon_types/bow/JSON/")
	daggers     = _load_json_dir(_BASE + "equipment/weapons/weapon_types/dagger/JSON/")
	greatswords = _load_json_dir(_BASE + "equipment/weapons/weapon_types/greatswords/JSON/")
	knives      = _load_json_dir(_BASE + "equipment/weapons/weapon_types/knife/JSON/")
	staves      = _load_json_dir(_BASE + "equipment/weapons/weapon_types/staff/JSON/")
	swords      = _load_json_dir(_BASE + "equipment/weapons/weapon_types/sword/JSON/")

	boots   = _load_json_dir(_BASE + "equipment/armor/armor_types/boots/JSON/")
	bottoms = _load_json_dir(_BASE + "equipment/armor/armor_types/bottoms/JSON/")
	chests  = _load_json_dir(_BASE + "equipment/armor/armor_types/chests/JSON/")
	gloves  = _load_json_dir(_BASE + "equipment/armor/armor_types/gloves/JSON/")
	helmets = _load_json_dir(_BASE + "equipment/armor/armor_types/helmet/JSON/")

	l_rings   = _load_json_dir(_BASE + "equipment/accessories/l_ring/JSON/")
	r_rings   = _load_json_dir(_BASE + "equipment/accessories/r_ring/JSON/")
	necklaces = _load_json_dir(_BASE + "equipment/accessories/necklace/JSON/")

	quest_items      = _load_json_dir(_BASE + "quest_items/JSON/")
	consumables      = _load_json_dir(_BASE + "consumables/JSON/")
	offensive_items  = _load_json_dir(_BASE + "usable_items/offensive_items/JSON/")
	defensive_items  = _load_json_dir(_BASE + "usable_items/defensive_items/JSON/")
	support_items    = _load_json_dir(_BASE + "usable_items/support_items/JSON/")


func _load_json_dir(path: String) -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	var dir := DirAccess.open(path)
	if dir == null:
		push_warning("ItemDatabase: cannot open %s" % path)
		return items
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var file := FileAccess.open(path + file_name, FileAccess.READ)
			if file:
				var parsed = JSON.parse_string(file.get_as_text())
				if parsed is Dictionary:
					items.append(parsed)
				else:
					push_warning("ItemDatabase: failed to parse %s" % (path + file_name))
		file_name = dir.get_next()
	dir.list_dir_end()
	return items
