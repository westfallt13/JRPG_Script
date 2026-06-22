class_name ConditionChecker

# Decides whether a condition is satisfied by a context. This is the foundation
# for "apply an effect only in certain situations" — effects carry an optional
# "condition", and the battle/UI code passes in a `context` describing the
# current situation.
#
# Condition formats (all optional — no condition means "always applies"):
#   null  /  {}  /  []                    -> always true
#   { "key": k, "op": o, "value": v }     -> one comparison: context[k] <op> v
#   [ clause, clause, ... ]               -> AND: every clause must pass
#
# Supported ops: "==", "!=", "<", "<=", ">", ">=", "in", "has".
#   "in"  -> actual is one of value (value is an Array)
#   "has" -> actual (an Array) contains value
#
# `context` is a plain Dictionary you build at the call site, e.g.
#   { "wearer_hp_pct": 0.25, "target_type": "undead", "wearer_statuses": ["Poison"] }
# Use the BattleContext key names (Combatant.build_context() builds them for you).
# Extend the system by adding ops in _compare() or new keys to your context — no
# other file needs to change.
#
# All methods are static: call ConditionChecker.passes(...), no instance needed.


static func passes(condition, context: Dictionary) -> bool:
	if condition == null:
		return true
	# A list of clauses: every one must pass (logical AND).
	if condition is Array:
		for clause in condition:
			if not passes(clause, context):
				return false
		return true
	# Anything that isn't a non-empty Dictionary is treated as "no condition".
	if not (condition is Dictionary) or condition.is_empty():
		return true
	var key: String = condition.get("key", "")
	var op: String = condition.get("op", "==")
	var value = condition.get("value", null)
	return _compare(context.get(key, null), op, value)


# Compares one actual value against an expected value with an operator. Ordering
# ops require two numbers; mismatched/missing operands fail safely (no crash).
static func _compare(actual, op: String, value) -> bool:
	match op:
		"==": return actual == value
		"!=": return actual != value
		"in": return value is Array and actual in value
		"has": return actual is Array and value in actual
	if not (_is_number(actual) and _is_number(value)):
		push_warning("ConditionChecker: op '%s' needs numeric operands" % op)
		return false
	match op:
		"<":  return actual < value
		"<=": return actual <= value
		">":  return actual > value
		">=": return actual >= value
	push_warning("ConditionChecker: unknown op '%s'" % op)
	return false


static func _is_number(v) -> bool:
	return v is int or v is float
