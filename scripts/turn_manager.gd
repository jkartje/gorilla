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
	# Check how many are alive
	var alive_count: int = get_alive_count()

	# If 0 or 1 alive → match is over
	if alive_count <= 1:
		var winner: Gorilla = null
		if alive_count == 1:
			for n in gorillas:
				var g: Gorilla = n as Gorilla
				if g != null and g.is_alive:
					winner = g
					break

		match_active = false
		current_index = -1
		emit_signal("match_over", winner)
		return

	if gorillas.is_empty():
		match_active = false
		current_index = -1
		return

	if current_index < 0 or current_index >= gorillas.size():
		current_index = 0

	# Find the next alive gorilla and start their turn
	var loops: int = 0
	while loops < gorillas.size():
		var g: Gorilla = gorillas[current_index] as Gorilla
		if g != null and g.is_alive:
			emit_signal("turn_started", g)
			return
		current_index = (current_index + 1) % gorillas.size()
		loops += 1

	# If we somehow looped with no alive gorillas, treat as match over
	match_active = false
	current_index = -1
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
