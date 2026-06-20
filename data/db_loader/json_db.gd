class_name JsonDB

# Central, reusable JSON access. Every per-folder loader script calls into this,
# so the actual file-reading logic lives in exactly one place.
#
# All methods are static: call them as JsonDB.read_json(...), no instance needed.


# Reads the JSON file at `path` and returns the parsed value (Dictionary or
# Array). Returns null on any failure (missing file, unreadable, bad JSON) so
# callers can decide how to react.
static func read_json(path: String):
	if not FileAccess.file_exists(path):
		push_warning("JsonDB: file not found: %s" % path)
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("JsonDB: cannot open %s (error %d)" % [path, FileAccess.get_open_error()])
		return null
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed == null:
		push_warning("JsonDB: failed to parse %s" % path)
	return parsed


# Turns an Array of object-dictionaries into a Dictionary keyed by `key_field`.
# index_by([{ "effect_name": "x", ... }], "effect_name") -> { "x": { ... } }
static func index_by(rows: Array, key_field: String) -> Dictionary:
	var table := {}
	for row in rows:
		if row is Dictionary and row.has(key_field):
			table[row[key_field]] = row
		else:
			push_warning("JsonDB: row missing key '%s', skipped" % key_field)
	return table


# Loads every *.json file in `dir_path` (one item per file) into a Dictionary
# keyed by each item's `key_field`. Missing/empty folder -> {} (with a warning
# only if the folder itself can't be opened). This is the "drop a file in to add
# an item" loader for weapons, armor, accessories, etc.
static func load_dir(dir_path: String, key_field: String) -> Dictionary:
	var items := {}
	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_warning("JsonDB: cannot open dir %s" % dir_path)
		return items
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		# .to_lower() so ".JSON" / ".Json" are matched too, not just ".json".
		if not dir.current_is_dir() and file_name.to_lower().ends_with(".json"):
			var parsed = read_json(dir_path.path_join(file_name))
			if parsed is Dictionary and parsed.has(key_field):
				items[parsed[key_field]] = parsed
			elif parsed is Dictionary:
				push_warning("JsonDB: %s missing key '%s', skipped" % [file_name, key_field])
		file_name = dir.get_next()
	dir.list_dir_end()
	return items


# Loads a single collection file shaped { root_key: [ {..}, {..} ] } into a
# Dictionary keyed by each entry's `key_field`. This is the loader for the
# *_effects files (one file holding an array of effects).
static func load_collection(path: String, root_key: String, key_field: String) -> Dictionary:
	var parsed = read_json(path)
	if not parsed is Dictionary:
		return {}
	return index_by(parsed.get(root_key, []), key_field)
