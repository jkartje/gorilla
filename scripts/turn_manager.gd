extends Node
class_name TurnManager

signal turn_started(gorilla: Gorilla)
signal turn_ended(gorilla: Gorilla)
signal match_over(winner: Gorilla)

var gorillas: Array = []          # Gorilla instances
var current_index: int = -1
var match_active: bool = false

func start_match(gorilla_list: Array) -> void:
	gorillas.clear()
	for g in gorilla_list:
		if g is Gorilla:
			gorillas.append(g)

	if gorillas.is_empty():
		match_active = false
		current_index = -1
		return

	match_active = true
	current_index = 0
	_start_alive_turn()

func _start_alive_turn() -> void:
	var alive_count: int = get_alive_count()

	# If 0 or 1 alive → match is over
	if alive_count <= 1:
		var winner: Gorilla = null
		if alive_count == 1:
			for n in gorillas:
				var gg: Gorilla = n as Gorilla
				if gg != null and gg.is_alive:
					winner = gg
					break

		match_active = false
		current_index = -1
		_set_all_turn_active(false)
		emit_signal("match_over", winner)
		return

	if current_index < 0 or current_index >= gorillas.size():
		current_index = 0

	# Find the next alive gorilla and start their turn
	var loops: int = 0
	while loops < gorillas.size():
		var g: Gorilla = gorillas[current_index] as Gorilla
		if g != null and g.is_alive:
			_set_all_turn_active(false)
			g.set_turn_active(true)
			emit_signal("turn_started", g)
			return

		current_index = (current_index + 1) % gorillas.size()
		loops += 1

	# No alive gorillas found
	match_active = false
	current_index = -1
	_set_all_turn_active(false)
	emit_signal("match_over", null)

func end_turn() -> void:
	if not match_active:
		return
	if gorillas.is_empty():
		match_active = false
		current_index = -1
		return

	var g: Gorilla = gorillas[current_index] as Gorilla
	if g != null:
		g.set_turn_active(false)
		emit_signal("turn_ended", g)

	current_index = (current_index + 1) % gorillas.size()
	_start_alive_turn()

func current_gorilla() -> Gorilla:
	if not match_active:
		return null
	if current_index < 0 or current_index >= gorillas.size():
		return null
	var g: Gorilla = gorillas[current_index] as Gorilla
	if g == null or not g.is_alive:
		return null
	return g

func get_alive_count() -> int:
	var c: int = 0
	for n in gorillas:
		var g: Gorilla = n as Gorilla
		if g != null and g.is_alive:
			c += 1
	return c

func _set_all_turn_active(active: bool) -> void:
	for n in gorillas:
		var g: Gorilla = n as Gorilla
		if g != null:
			g.set_turn_active(active)
