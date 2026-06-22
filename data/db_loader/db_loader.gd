extends Node

# Central data access point (autoloaded as "DbLoader").
#
# Each category maps to a per-folder loader script (the dict.* / *_effects files
# next to each JSON/ folder). Those scripts know their own path + key field; this
# file just aggregates them and hands data to the rest of the game.
#
# Categories load lazily: a category's JSON is read the first time it is
# requested, then cached, so startup stays cheap (see guide.to.db.loader.md).
#
# Usage from anywhere:
#   DbLoader.get_item("swords", "Test Sword")     # one item, or null
#   DbLoader.get_category("helmets")              # whole category as a Dictionary
#   DbLoader.get_categories(["axes", "swords"])   # several at once
#   DbLoader.load_all()                           # force-load everything now
#   DbLoader.reload("swords")                     # re-read one category from disk

const _BASE := "res://JRPG_Code/JRPG_Script/data/item_database/"
const _STATS_BASE := "res://JRPG_Code/JRPG_Script/data/stats/"

# category name -> preloaded per-folder loader script (each exposes static get_all()).
var _loaders := {}
# category name -> loaded Dictionary, cached after first access.
var _cache := {}


func _ready() -> void:
	_loaders = {
		# Weapons
		"axes":        preload(_BASE + "equipment/weapons/weapon_types/axe/dict.axes.gd"),
		"bows":        preload(_BASE + "equipment/weapons/weapon_types/bow/dict.bows.gd"),
		"daggers":     preload(_BASE + "equipment/weapons/weapon_types/dagger/dict.dagger.gd"),
		"greatswords": preload(_BASE + "equipment/weapons/weapon_types/greatswords/dict.greatswords.gd"),
		"knives":      preload(_BASE + "equipment/weapons/weapon_types/knife/dict.knives.gd"),
		"staves":      preload(_BASE + "equipment/weapons/weapon_types/staff/dict.staves.gd"),
		"swords":      preload(_BASE + "equipment/weapons/weapon_types/sword/dict.swords.gd"),

		# Armor
		"boots":   preload(_BASE + "equipment/armor/armor_types/boots/dict.boots.gd"),
		"bottoms": preload(_BASE + "equipment/armor/armor_types/bottoms/dict.bottoms.gd"),
		"chests":  preload(_BASE + "equipment/armor/armor_types/chests/dict.chests.gd"),
		"gloves":  preload(_BASE + "equipment/armor/armor_types/gloves/dict.gloves.gd"),
		"helmets": preload(_BASE + "equipment/armor/armor_types/helmet/dict.helmets.gd"),

		# Accessories
		"l_rings":   preload(_BASE + "equipment/accessories/l_ring/dict.l_ring.gd"),
		"r_rings":   preload(_BASE + "equipment/accessories/r_ring/dict.r_ring.gd"),
		"necklaces": preload(_BASE + "equipment/accessories/necklace/dict.necklaces.gd"),

		# Other items
		"quest_items":     preload(_BASE + "quest_items/quest_items.gd"),
		"consumables":     preload(_BASE + "consumables/consumables.gd"),
		"defensive_items": preload(_BASE + "usable_items/defensive_items/defensive_items.gd"),
		"offensive_items": preload(_BASE + "usable_items/offensive_items/offensive_items.gd"),
		"support_items":   preload(_BASE + "usable_items/support_items/support_items.gd"),

		# Effects (collection files)
		"armor_effects":     preload(_BASE + "equipment/armor/armor_effects/armor_effects.gd"),
		"accessory_effects": preload(_BASE + "equipment/accessories/accessory_effects/accessory_effects.gd"),
		"axe_effects":        preload(_BASE + "equipment/weapons/weapon_effects/axe/dictionary_axe_effects.gd"),
		"bow_effects":        preload(_BASE + "equipment/weapons/weapon_effects/bow/dictionary_bow_effects.gd"),
		"dagger_effects":     preload(_BASE + "equipment/weapons/weapon_effects/dagger/dictionary_dagger_effects.gd"),
		"greatsword_effects": preload(_BASE + "equipment/weapons/weapon_effects/greatswords/dictionary_greatswords_effects.gd"),
		"knife_effects":      preload(_BASE + "equipment/weapons/weapon_effects/knife/dictionary_knives_effects.gd"),
		"staff_effects":      preload(_BASE + "equipment/weapons/weapon_effects/staff/dictionary_staves_effects.gd"),
		"sword_effects":      preload(_BASE + "equipment/weapons/weapon_effects/sword/dictionary_swords_effects.gd"),

		# Stats (collection files; migrated from the old loose-dict scripts)
		"attributes":        preload(_STATS_BASE + "stat_types/attributes/attribute_stats.gd"),
		"health_and_mana":   preload(_STATS_BASE + "stat_types/health_and_mana/health_and_mana.gd"),
		"status_conditions": preload(_STATS_BASE + "status_conditions/status_conditions.gd"),
		"magic_abilities":   preload(_STATS_BASE + "ability_and_stability/ability_types/magic_abilities/magic_abilities.gd"),
		"enemy_abilities":   preload(_STATS_BASE + "ability_and_stability/ability_types/enemy_abilities/enemy_abilities.gd"),
		"level_curve":       preload(_STATS_BASE + "level_ups/level_value_database/level_value_database.gd"),
	}


# Returns one category as a name-keyed Dictionary. Read from disk on first
# access, cached thereafter. Unknown category -> {} (with a warning).
func get_category(category: String) -> Dictionary:
	if _cache.has(category):
		return _cache[category]
	if not _loaders.has(category):
		push_warning("DbLoader: unknown category '%s'" % category)
		return {}
	var loaded: Dictionary = _loaders[category].get_all()
	_cache[category] = loaded
	return loaded


# Returns a single item within a category by its key, or null if not found.
# (Effect resolution lives in EquipmentEffects — e.g. EquipmentEffects.for_item.)
func get_item(category: String, item_key: String):
	return get_category(category).get(item_key, null)


# Returns several categories at once: { "axes": {...}, "swords": {...} }.
func get_categories(categories: Array) -> Dictionary:
	var out := {}
	for category in categories:
		out[category] = get_category(category)
	return out


# Every category name this loader knows about.
func category_names() -> Array:
	return _loaders.keys()


# Force-load (or reload) every category now. Useful for a loading screen, or to
# pick up JSON edited at runtime.
func load_all() :
	for category in _loaders:
		_cache[category] = _loaders[category].get_all()


# Drop a single category from the cache so its next access re-reads from disk.
func reload(category: String) -> void:
	_cache.erase(category)


# Drop all cached data; everything reloads on next access.
func clear_cache() -> void:
	_cache.clear()
