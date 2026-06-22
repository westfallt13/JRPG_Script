class_name Combatant
extends RefCounted

# One entity's LIVE state — the glue that ties the data layer together (Plan, Phase 2).
#
# The data layer can load and resolve effects, but nothing represented "a level-12
# hero wearing the Test Sword who is currently Poisoned." That entity is this class.
# It composes:
#   - base attributes      (copied from the "attributes" template, then live/mutable)
#   - HP / MP pools         (current + max, live)
#   - equipment per slot    (slot -> { category, key }; category is needed to resolve effects)
#   - active statuses        (Array[String] of status_condition names)
# and exposes derived reads (hp_pct, total_stat) plus build_context(), the ONE place
# that turns this combatant into a ConditionChecker/EquipmentEffects context.
#
# Templates vs. live state (Plan, Phase 1/2 split): the JSON categories hold DEFAULTS;
# this object holds the per-character values that change during play. seed_from_templates()
# copies defaults in once; everything after that is this combatant's own state.
#
# DbLoader dependency: total_stat()/derived_stat()/active_equipment_effects() resolve
# gear through the global DbLoader autoload + EquipmentEffects, so they only work at
# runtime (the autoload isn't live in the editor). The autoload-free surface —
# construction, seed_from_templates(loader), equip, hp_pct, statuses, build_context
# (plus EffectResolver's pure aggregation) — is what tools/combatant_test.gd exercises;
# the live path is shown in node_2dtestdb.gd.

# Logical equipment slots. A "weapon" slot can hold ANY weapon category (swords,
# axes, …), which is exactly why each slot stores its item's category alongside the
# key — a bare slot->key map couldn't tell EquipmentEffects which collection to read.
const SLOTS := [
	"weapon", "helmet", "chest", "bottoms", "gloves", "boots",
	"l_ring", "r_ring", "necklace",
]

var display_name: String = "Unnamed"
var level: int = 1

var base_attributes: Dictionary = {}   # "strength" -> int  (live; seeded from template)
var max_health: int = 0
var current_health: int = 0
var max_mana: int = 0
var current_mana: int = 0

var equipment: Dictionary = {}          # slot -> { "category": String, "key": String }
var statuses: Array[String] = []        # active status_condition names


func _init(p_name := "Unnamed", p_level := 1) -> void:
	display_name = p_name
	level = p_level


# --- Construction from the Phase 1 templates ---------------------------------

# Build a combatant pre-filled with the JSON defaults. Production call (uses the
# global DbLoader autoload).
static func from_templates(p_name := "Unnamed", p_level := 1) -> Combatant:
	return Combatant.new(p_name, p_level).seed_from_templates()


# Copy defaults from the "attributes" and "health_and_mana" categories into this
# combatant's live state. Returns self so it chains. Pass `loader` to read from a
# specific DbLoader instance (used by the editor test, where the autoload isn't
# live); leave it null in game code to use the global DbLoader.
func seed_from_templates(loader = null) -> Combatant:
	var db = loader if loader != null else DbLoader

	base_attributes.clear()
	for attr_name in db.get_category("attributes"):
		base_attributes[attr_name] = int(_template_value(db, "attributes", attr_name))

	max_health     = int(_template_value(db, "health_and_mana", "max_health"))
	current_health = int(_template_value(db, "health_and_mana", "current_health", max_health))
	max_mana       = int(_template_value(db, "health_and_mana", "max_mana"))
	current_mana   = int(_template_value(db, "health_and_mana", "current_mana", max_mana))
	return self


# One template entry's "base_value", with a fallback when the entry is missing.
static func _template_value(db, category: String, entry_key: String, fallback := 0) -> float:
	var entry = db.get_category(category).get(entry_key, null)
	if entry is Dictionary:
		return float(entry.get("base_value", fallback))
	return float(fallback)


# --- Equipment --------------------------------------------------------------

# Put an item in a slot. `category` is its DbLoader category (e.g. "swords"),
# `item_key` its key within that category (e.g. "Test Sword"). Returns false on an
# unknown slot. Doesn't verify the item exists here (that needs the DB) — use
# validate() at runtime for that.
func equip(slot: String, category: String, item_key: String) -> bool:
	if slot not in SLOTS:
		push_warning("Combatant: unknown equip slot '%s'" % slot)
		return false
	equipment[slot] = {"category": category, "key": item_key}
	return true


func unequip(slot: String) -> void:
	equipment.erase(slot)


func is_equipped(slot: String) -> bool:
	return equipment.has(slot)


# { "category": ..., "key": ... } for a slot, or {} if the slot is empty.
func equipped(slot: String) -> Dictionary:
	return equipment.get(slot, {})


# --- Statuses ---------------------------------------------------------------

func has_status(status_name: String) -> bool:
	return status_name in statuses


func add_status(status_name: String) -> void:
	if status_name not in statuses:
		statuses.append(status_name)


func remove_status(status_name: String) -> void:
	statuses.erase(status_name)


# --- Derived reads ----------------------------------------------------------

func hp_pct() -> float:
	return BattleContext.pct(current_health, max_health)


func mp_pct() -> float:
	return BattleContext.pct(current_mana, max_mana)


# This combatant's base value for an attribute (0 if it has no such attribute).
func base_stat(stat: String) -> int:
	return int(base_attributes.get(stat, 0))


# The combatant's total for an attribute: its base plus every equipped item's
# currently-active contributions to that stat (conditions evaluated against `context`,
# defaulting to build_context()). Runtime path — resolves gear through the global
# DbLoader/EquipmentEffects, aggregated by EffectResolver as (base + adds) * (1 + mults).
func total_stat(stat: String, context: Dictionary = {}) -> float:
	return derived_stat(stat, float(base_stat(stat)), context)


# Apply this combatant's active equipment modifiers for `stat` on top of an
# arbitrary `base`. Use for derived stats whose base ISN'T a stored attribute —
# e.g. per-attack damage: derived_stat("damage", weapon_base_damage, ctx).
func derived_stat(stat: String, base: float, context: Dictionary = {}) -> float:
	var ctx := context if not context.is_empty() else build_context()
	return EffectResolver.derived(base, stat, active_equipment_effects(ctx))


# Per-target { "add": x, "mult": y } modifiers from all currently-active gear — the
# "derived-stats dictionary" of Plan Phase 3. Handy for character sheets / tooltips.
func equipment_modifiers(context: Dictionary = {}) -> Dictionary:
	var ctx := context if not context.is_empty() else build_context()
	return EffectResolver.aggregate(active_equipment_effects(ctx))


# --- Context + effect resolution (runtime; uses the global DbLoader) ---------

# Turn this combatant into a ConditionChecker/EquipmentEffects context. This is the
# single home for the wearer-side keys (wearer_hp_pct, wearer_statuses, …): because
# everything goes through BattleContext here, the data side and code side can't drift
# on spelling (closes the "statuses" vs "wearer_statuses" footgun, Plan fix-list #6).
func build_context() -> Dictionary:
	return BattleContext.new() \
		.set_wearer(current_health, max_health, level, statuses) \
		.set_wearer_mp(current_mana, max_mana) \
		.to_dict()


# Every resolved, currently-active effect across all equipped slots, each effect's
# optional condition evaluated against `context` (defaults to build_context()).
# Runtime path — uses the global DbLoader/EquipmentEffects.
func active_equipment_effects(context: Dictionary = {}) -> Array:
	var ctx := context if not context.is_empty() else build_context()
	var out: Array = []
	for slot in equipment:
		var e: Dictionary = equipment[slot]
		out.append_array(EquipmentEffects.active_for_item_key(e["category"], e["key"], ctx))
	return out


# Report equipped items whose category/key don't resolve in the DB (typos, removed
# content). Empty array == everything resolves. Runtime path. `loader` overridable
# as in seed_from_templates.
func validate(loader = null) -> Array:
	var db = loader if loader != null else DbLoader
	var bad: Array = []
	for slot in equipment:
		var e: Dictionary = equipment[slot]
		if not (db.get_item(e["category"], e["key"]) is Dictionary):
			bad.append("%s: %s/%s" % [slot, e["category"], e["key"]])
	return bad


func _to_string() -> String:
	return "Combatant(%s, Lv%d, HP %d/%d, MP %d/%d, statuses=%s, equipped=%s)" % [
		display_name, level, current_health, max_health, current_mana, max_mana,
		str(statuses), str(equipment.keys()),
	]
