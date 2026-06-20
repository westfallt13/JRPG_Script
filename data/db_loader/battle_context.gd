class_name BattleContext
extends RefCounted

# Shared vocabulary for ConditionChecker contexts.
#
# An effect's "condition" in JSON references these key NAMES as strings; GDScript
# builds the matching context with the SAME names via the constants below — so the
# data side and the code side can never drift apart on spelling.
#
# Build one fluently, then hand .to_dict() to EquipmentEffects.active_for_item*:
#   var ctx := BattleContext.new() \
#       .set_wearer(hp, max_hp, level, wearer_statuses) \
#       .set_target("undead", t_hp, t_max_hp) \
#       .set_action("physical", "fire", false, turn) \
#       .to_dict()
#   var fx := EquipmentEffects.active_for_item_key("swords", weapon_name, ctx)
#
# Read values back in calc code with the typed, crash-safe getters:
#   var hp_frac := BattleContext.num(ctx, BattleContext.WEARER_HP_PCT)

# --- Canonical keys ---------------------------------------------------------
# Wearer: the entity whose equipment/effects are being evaluated.
const WEARER_HP       := "wearer_hp"        # int    current HP
const WEARER_MAX_HP   := "wearer_max_hp"    # int
const WEARER_HP_PCT   := "wearer_hp_pct"    # float  0.0..1.0 (derived)
const WEARER_MP       := "wearer_mp"        # int    current MP
const WEARER_MAX_MP   := "wearer_max_mp"    # int
const WEARER_MP_PCT   := "wearer_mp_pct"    # float  0.0..1.0 (derived)
const WEARER_LEVEL    := "wearer_level"     # int
const WEARER_STATUSES := "wearer_statuses"  # Array[String]  status names

# Target: the entity being acted upon.
const TARGET_TYPE     := "target_type"      # String  e.g. "undead", "beast"
const TARGET_HP       := "target_hp"        # int
const TARGET_MAX_HP   := "target_max_hp"    # int
const TARGET_HP_PCT   := "target_hp_pct"    # float  0.0..1.0 (derived)
const TARGET_LEVEL    := "target_level"     # int
const TARGET_STATUSES := "target_statuses"  # Array[String]
const TARGET_IS_BOSS  := "target_is_boss"   # bool

# Action / battle-wide.
const DAMAGE_TYPE     := "damage_type"      # String  "physical" | "magical"
const ELEMENT         := "element"          # String  "fire" | "ice" | ...
const IS_CRIT         := "is_crit"          # bool    was the hit a critical
const TURN            := "turn"             # int     current turn number

var _data: Dictionary = {}


# --- Builder (chainable; each setter returns self) --------------------------

func set_wearer(hp: int, max_hp: int, level: int = 1, statuses: Array = []) -> BattleContext:
	_data[WEARER_HP] = hp
	_data[WEARER_MAX_HP] = max_hp
	_data[WEARER_HP_PCT] = pct(hp, max_hp)
	_data[WEARER_LEVEL] = level
	_data[WEARER_STATUSES] = statuses
	return self


func set_wearer_mp(mp: int, max_mp: int) -> BattleContext:
	_data[WEARER_MP] = mp
	_data[WEARER_MAX_MP] = max_mp
	_data[WEARER_MP_PCT] = pct(mp, max_mp)
	return self


func set_target(type: String, hp: int, max_hp: int, level: int = 1, statuses: Array = [], is_boss: bool = false) -> BattleContext:
	_data[TARGET_TYPE] = type
	_data[TARGET_HP] = hp
	_data[TARGET_MAX_HP] = max_hp
	_data[TARGET_HP_PCT] = pct(hp, max_hp)
	_data[TARGET_LEVEL] = level
	_data[TARGET_STATUSES] = statuses
	_data[TARGET_IS_BOSS] = is_boss
	return self


func set_action(damage_type: String = "physical", element: String = "", is_crit: bool = false, turn: int = 0) -> BattleContext:
	_data[DAMAGE_TYPE] = damage_type
	_data[ELEMENT] = element
	_data[IS_CRIT] = is_crit
	_data[TURN] = turn
	return self


# Escape hatch for a custom/one-off key not covered above.
func put(key: String, value) -> BattleContext:
	_data[key] = value
	return self


# The finished context to pass to ConditionChecker / EquipmentEffects.
func to_dict() -> Dictionary:
	return _data


# --- Static helpers ---------------------------------------------------------

# Safe fraction; 0.0 when maximum is 0 (avoids divide-by-zero).
static func pct(current: int, maximum: int) -> float:
	return float(current) / maximum if maximum > 0 else 0.0


# Typed, crash-safe reads for calc code. Each returns `default` if the key is
# missing or the stored value is the wrong type.
static func num(ctx: Dictionary, key: String, default: float = 0.0) -> float:
	var v = ctx.get(key, default)
	return float(v) if (v is int or v is float) else default


static func text(ctx: Dictionary, key: String, default: String = "") -> String:
	var v = ctx.get(key, default)
	return v if v is String else default


static func flag(ctx: Dictionary, key: String, default: bool = false) -> bool:
	var v = ctx.get(key, default)
	return v if v is bool else default


static func list(ctx: Dictionary, key: String) -> Array:
	var v = ctx.get(key, [])
	return v if v is Array else []
