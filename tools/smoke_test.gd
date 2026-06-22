@tool
extends EditorScript

# Smoke test — load every DbLoader category and report its item count.
#
# This is the project's "I watched it work" check (Plan, Phase 0). It turns
# "I think the data loads" into a printed table of counts you can eyeball in
# seconds, and it surfaces parse/JSON problems as warnings in the same run.
#
# HOW TO RUN (no Godot CLI needed):
#   1. Open this file in the Godot script editor.
#   2. File ▸ Run  (or Ctrl+Shift+X).
#   3. Read the Output panel: a count per category, a total, and a flag on any
#      empty category. Any push_warning() from a loader (missing file, bad JSON,
#      a row missing its key field) prints inline in the same panel.
#
# WHY IT INSTANTIATES DbLoader DIRECTLY (instead of using the autoload):
#   Autoloads aren't guaranteed to be live inside the editor, but an EditorScript
#   always is. Building a fresh DbLoader and calling _ready() ourselves drives the
#   exact same loader registry the game uses at runtime, so the counts are real —
#   without depending on editor autoload state. (If you add the Godot CLI later,
#   a headless SceneTree variant is a small rewrite; see Plan, Phase 0 Option A.)

const DB_LOADER := preload("res://JRPG_Code/JRPG_Script/data/db_loader/db_loader.gd")


func _run() -> void:
	var db: Node = DB_LOADER.new()
	db._ready()        # populates the category -> loader registry (normally done by the tree)
	db.load_all()      # force-read + cache every category now

	var names: Array = db.category_names()
	names.sort()       # stable, readable order

	print("──────────────────────────────────────────────")
	print("DbLoader smoke test — %d categories" % names.size())
	print("──────────────────────────────────────────────")

	var total := 0
	var empties: Array = []
	for category in names:
		var count: int = db.get_category(category).size()
		total += count
		var flag := "  (empty)" if count == 0 else ""
		print("  %-20s %4d%s" % [category, count, flag])
		if count == 0:
			empties.append(category)

	print("──────────────────────────────────────────────")
	print("  TOTAL items: %d across %d categories" % [total, names.size()])
	if empties.is_empty():
		print("  No empty categories.")
	else:
		# Empty isn't necessarily wrong (scaffolded categories exist on purpose);
		# it's just the thing most worth a second look after a migration.
		print("  Empty categories (%d): %s" % [empties.size(), ", ".join(empties)])
	print("──────────────────────────────────────────────")

	db.free()          # EditorScript owns this node; release it
