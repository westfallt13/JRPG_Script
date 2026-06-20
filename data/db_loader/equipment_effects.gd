class_name EquipmentEffects

# Standardized resolver linking an equipment item to the effect data it grants.
#
# Each item names its effect(s) in a per-type field (kept as-is in the JSON):
#   weapons      -> "weapon_effect"
#   armor        -> "armor_effects"
#   accessories  -> "accessory_effects"
# That field holds an effect name, or a list of effect names. Every name is
# looked up by "effect_name" in the matching effects collection (via DbLoader).
#
# All access goes through ONE uniform set of functions no matter the equipment
# type — the LINKS table routes each item category to (a) the field that names
# its effects and (b) the effects collection to resolve them against. Add a row
# to support a new category.
#
# Typical flow (player picks up a sword):
#   var item    = DbLoader.get_item("swords", name)         # db_loader grabs the item
#   var effects = EquipmentEffects.for_item("swords", item) # resolve its effects
#   # effects -> [ { "effect_name": "...", "description": "...", "value": ... }, ... ]
# Feed `effects` to UI text, attribute math, damage calc, or status logic.
#
# All methods are static: call EquipmentEffects.for_item(...), no instance needed.

const LINKS := {
	# Weapons: each weapon type resolves against its own *_effects collection.
	"axes":        {"field": "weapon_effect", "effects": "axe_effects"},
	"bows":        {"field": "weapon_effect", "effects": "bow_effects"},
	"daggers":     {"field": "weapon_effect", "effects": "dagger_effects"},
	"greatswords": {"field": "weapon_effect", "effects": "greatsword_effects"},
	"knives":      {"field": "weapon_effect", "effects": "knife_effects"},
	"staves":      {"field": "weapon_effect", "effects": "staff_effects"},
	"swords":      {"field": "weapon_effect", "effects": "sword_effects"},

	# Armor: all types share the one armor_effects collection.
	"boots":   {"field": "armor_effects", "effects": "armor_effects"},
	"bottoms": {"field": "armor_effects", "effects": "armor_effects"},
	"chests":  {"field": "armor_effects", "effects": "armor_effects"},
	"gloves":  {"field": "armor_effects", "effects": "armor_effects"},
	"helmets": {"field": "armor_effects", "effects": "armor_effects"},

	# Accessories: all share the one accessory_effects collection.
	"l_rings":   {"field": "accessory_effects", "effects": "accessory_effects"},
	"r_rings":   {"field": "accessory_effects", "effects": "accessory_effects"},
	"necklaces": {"field": "accessory_effects", "effects": "accessory_effects"},
}


# True if `category` is linked to an effects collection.
static func is_linked(category: String) -> bool:
	return LINKS.has(category)


# The item-JSON field that names effects for this category ("weapon_effect", …),
# or "" if the category isn't linked.
static func effect_field(category: String) -> String:
	var link = LINKS.get(category, null)
	return link["field"] if link else ""


# The effects collection this category resolves against ("sword_effects",
# "armor_effects", …), or "" if the category isn't linked.
static func effects_category(category: String) -> String:
	var link = LINKS.get(category, null)
	return link["effects"] if link else ""


# Resolve the effect objects an item grants. Reads the item's effect-name field
# (a single name or a list of names) and looks each up in the category's effects
# collection. Always returns a clean Array — missing/empty field, unlinked
# category, or unresolved names yield []/skips (with a warning per missing name).
static func for_item(category: String, item: Dictionary) -> Array:
	var link = LINKS.get(category, null)
	if link == null:
		return []
	var names := _as_name_list(item.get(link["field"], null))
	if names.is_empty():
		return []
	var table: Dictionary = DbLoader.get_category(link["effects"])
	var resolved := []
	for effect_name in names:
		if table.has(effect_name):
			resolved.append(table[effect_name])
		else:
			push_warning("EquipmentEffects: effect '%s' not found in '%s' (category '%s')"
				% [effect_name, link["effects"], category])
	return resolved


# Same as for_item, but fetches the item from DbLoader by its key first.
static func for_item_key(category: String, item_key: String) -> Array:
	var item = DbLoader.get_item(category, item_key)
	if not item is Dictionary:
		return []
	return for_item(category, item)


# A deep copy of the item with its resolved effects attached under "_effects",
# leaving the cached source data untouched. Convenient for menu/battle code that
# wants the item and its effects together in one object.
static func with_effects(category: String, item_key: String) -> Dictionary:
	var item = DbLoader.get_item(category, item_key)
	if not item is Dictionary:
		return {}
	var bundle: Dictionary = item.duplicate(true)
	bundle["_effects"] = for_item(category, item)
	return bundle


# Like for_item, but keeps only effects whose optional "condition" passes for the
# given `context` (battle state, wearer stats, target info, ...). Effects with no
# "condition" always pass. This is the gate for "apply only in certain situations":
# resolve everything, then filter by ConditionChecker.
static func active_for_item(category: String, item: Dictionary, context: Dictionary) -> Array:
	var active := []
	for effect in for_item(category, item):
		if ConditionChecker.passes(effect.get("condition", null), context):
			active.append(effect)
	return active


# Same as active_for_item, but fetches the item from DbLoader by its key first.
static func active_for_item_key(category: String, item_key: String, context: Dictionary) -> Array:
	var item = DbLoader.get_item(category, item_key)
	if not item is Dictionary:
		return []
	return active_for_item(category, item, context)


# Direct lookup of a single effect by category + effect_name (e.g. tooltips or
# tests). Returns the effect Dictionary, or {} if not found. The category picks
# the correct collection (so "swords" reads sword_effects, "boots" reads
# armor_effects, etc.) — this is why lookups are category-driven, not by a bare
# "weapon"/"armor" type: a weapon's effects live in its own per-type collection.
static func get_effect(category: String, effect_name: String) -> Dictionary:
	var link = LINKS.get(category, null)
	if link == null:
		return {}
	var effect = DbLoader.get_category(link["effects"]).get(effect_name, null)
	return effect if effect is Dictionary else {}


# Normalizes a field value into an Array of effect-name strings. Accepts a single
# name (String), a list of names (Array), or "nothing" ({} / null / "").
static func _as_name_list(value) -> Array:
	if value is Array:
		return value
	if value is String and value != "":
		return [value]
	return []
