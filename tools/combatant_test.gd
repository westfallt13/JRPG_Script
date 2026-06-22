@tool
extends EditorScript

# Combatant test — verifies the autoload-FREE surface of the Combatant (Plan, Phase 2).
#
# HOW TO RUN: open this file in the Godot script editor, File ▸ Run (Ctrl+Shift+X),
# read the PASS/FAIL lines in the Output panel.
#
# WHY ONLY PART OF THE CLASS: total_stat()/active_equipment_effects()/validate()
# resolve gear through the global DbLoader autoload, which isn't live in the editor.
# So this builds its own DbLoader instance and injects it (seed_from_templates(db)),
# and tests the rest directly. The live, gear-resolving path is exercised at runtime
# in node_2dtestdb.gd instead — together they cover the whole class.

const DB_LOADER := preload("res://JRPG_Code/JRPG_Script/data/db_loader/db_loader.gd")
const COMBATANT := preload("res://JRPG_Code/JRPG_Script/data/combatant/combatant.gd")
const RESOLVER := preload("res://JRPG_Code/JRPG_Script/data/db_loader/effect_resolver.gd")
const LEVELING := preload("res://JRPG_Code/JRPG_Script/data/stats/level_ups/level_ups.gd")

var _pass := 0
var _fail := 0


func _run() -> void:
	var db = DB_LOADER.new()
	db._ready()   # build the category registry without needing the autoload

	print("──────────────────────────────────────────────")
	print("Combatant test (autoload-free surface)")
	print("──────────────────────────────────────────────")

	# --- seed_from_templates (injected loader) ---
	var c = COMBATANT.new("Test Hero", 12)
	c.seed_from_templates(db)
	check("seeded 6 base attributes", c.base_attributes.size() == 6)
	check("strength default is 10", c.base_stat("strength") == 10)
	check("base_stat unknown attr -> 0", c.base_stat("charisma") == 0)
	check("max_health seeded to 100", c.max_health == 100)
	check("current_health seeded to 100", c.current_health == 100)
	check("max_mana seeded to 100", c.max_mana == 100)

	# --- equip ---
	check("equip valid slot returns true", c.equip("weapon", "swords", "Test Sword") == true)
	c.equip("boots", "boots", "Test Boots")
	check("weapon slot is equipped", c.is_equipped("weapon"))
	check("equipped() returns category+key",
		c.equipped("weapon").get("category") == "swords" and c.equipped("weapon").get("key") == "Test Sword")
	check("equip invalid slot returns false", c.equip("tail", "swords", "Test Sword") == false)
	check("invalid slot not stored", not c.is_equipped("tail"))
	c.unequip("boots")
	check("unequip clears the slot", not c.is_equipped("boots"))

	# --- statuses ---
	c.add_status("Poison")
	c.add_status("Poison")   # dedup
	c.add_status("Burn")
	check("add_status dedups", c.statuses.size() == 2)
	check("has_status true", c.has_status("Poison"))
	c.remove_status("Burn")
	check("remove_status works", not c.has_status("Burn"))

	# --- derived reads ---
	c.current_health = 25
	c.max_health = 100
	check("hp_pct computes fraction", is_equal_approx(c.hp_pct(), 0.25))
	c.max_health = 0
	check("hp_pct guards divide-by-zero", c.hp_pct() == 0.0)

	# --- build_context: the single home for wearer keys (closes drift #6) ---
	var hero = COMBATANT.new("Ctx Hero", 7)
	hero.seed_from_templates(db)
	hero.current_health = 30
	hero.max_health = 100
	hero.current_mana = 50
	hero.max_mana = 100
	hero.add_status("Poison")
	var ctx: Dictionary = hero.build_context()
	var ws: Array = ctx.get("wearer_statuses", [])
	check("ctx uses canonical 'wearer_statuses' (not bare 'statuses')",
		ctx.has("wearer_statuses") and not ctx.has("statuses"))
	check("ctx wearer_statuses carries the status", ws.size() == 1 and ws[0] == "Poison")
	check("ctx wearer_hp_pct derived = 0.30", is_equal_approx(float(ctx.get("wearer_hp_pct")), 0.30))
	check("ctx wearer_mp_pct derived = 0.50", is_equal_approx(float(ctx.get("wearer_mp_pct")), 0.50))
	check("ctx wearer_level set", int(ctx.get("wearer_level")) == 7)

	# --- EffectResolver: pure aggregation of stat_mod effects (Phase 3) ---
	var fx := [
		{"effect_name": "keen_edge",     "kind": "stat_mod", "target": "crit_chance", "op": "add",  "value": 0.15},
		{"effect_name": "defense_boost", "kind": "stat_mod", "target": "defense",      "op": "mult", "value": 0.10},
		{"effect_name": "low_hp_rage",   "kind": "stat_mod", "target": "damage",       "op": "mult", "value": 0.25},
		{"effect_name": "flavor",        "description": "no kind -> ignored",          "value": 99.0},
	]
	var mods: Dictionary = RESOLVER.aggregate(fx)
	check("aggregate keeps only targeted stat_mods (3)", mods.size() == 3 and not mods.has(""))
	check("crit_chance add aggregated", is_equal_approx(mods["crit_chance"]["add"], 0.15))
	check("defense mult aggregated", is_equal_approx(mods["defense"]["mult"], 0.10))
	check("apply = (base+add)*(1+mult): flat add", is_equal_approx(RESOLVER.apply(0.0, mods["crit_chance"]), 0.15))
	check("derived crit on base 0 -> 0.15", is_equal_approx(RESOLVER.derived(0.0, "crit_chance", fx), 0.15))
	check("derived damage base 100 * 1.25 -> 125", is_equal_approx(RESOLVER.derived(100.0, "damage", fx), 125.0))
	check("derived unaffected stat -> base", is_equal_approx(RESOLVER.derived(10.0, "luck", fx), 10.0))
	# percentage mults stack additively: two +25% -> +50% (x1.5), not x1.5625
	var two := [
		{"kind": "stat_mod", "target": "damage", "op": "mult", "value": 0.25},
		{"kind": "stat_mod", "target": "damage", "op": "mult", "value": 0.25},
	]
	check("two mults stack additively -> x1.5", is_equal_approx(RESOLVER.derived(100.0, "damage", two), 150.0))

	# --- Leveling (injected curve -> fully testable without the autoload) ---
	var curve := {
		1: {"level": 1, "xp_to_reach": 0,   "gains": {}},
		2: {"level": 2, "xp_to_reach": 100, "gains": {"max_health": 10, "strength": 2}},
		3: {"level": 3, "xp_to_reach": 250, "gains": {"max_health": 10, "vitality": 1}},
	}
	check("level_for_xp: 120 -> level 2", LEVELING.level_for_xp(120, curve) == 2)
	check("level_for_xp: 0 -> level 1", LEVELING.level_for_xp(0, curve) == 1)
	check("xp_to_reach(3) == 250", LEVELING.xp_to_reach(3, curve) == 250)
	check("max_level(curve) == 3", LEVELING.max_level(curve) == 3)

	var lc = COMBATANT.new("Leveler", 1)
	lc.seed_from_templates(db)   # strength 10, max_health 100, current_health 100
	var gained1: Array = LEVELING.grant_xp(lc, 120, curve)
	check("grant 120xp -> gained [2]", gained1.size() == 1 and gained1[0] == 2)
	check("now level 2", lc.level == 2)
	check("xp recorded", lc.xp == 120)
	check("strength grew 10 -> 12", lc.base_stat("strength") == 12)
	check("max_health grew 100 -> 110", lc.max_health == 110)
	check("current_health rose with the pool (110)", lc.current_health == 110)

	var gained2: Array = LEVELING.grant_xp(lc, 200, curve)   # total 320 -> crosses level 3
	check("grant 200 more (320 total) -> gained [3]", gained2.size() == 1 and gained2[0] == 3)
	check("now level 3", lc.level == 3)
	check("vitality grew 10 -> 11", lc.base_stat("vitality") == 11)
	check("max_health 110 -> 120", lc.max_health == 120)

	var gained3: Array = LEVELING.grant_xp(lc, 9999, curve)  # past the top of the curve
	check("XP past max level grants no level", gained3.is_empty() and lc.level == 3)

	print("──────────────────────────────────────────────")
	print("  %d passed, %d failed" % [_pass, _fail])
	print("  %s" % ("ALL GREEN" if _fail == 0 else "SOME CHECKS FAILED — see [FAIL] lines above"))
	print("──────────────────────────────────────────────")

	db.free()


func check(label: String, cond: bool) -> void:
	if cond:
		_pass += 1
		print("  [PASS] %s" % label)
	else:
		_fail += 1
		print("  [FAIL] %s" % label)
