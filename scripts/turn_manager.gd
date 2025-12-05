extends Node
class_name TurnManager

signal turn_started(gorilla: Gorilla)
signal turn_ended(gorilla: Gorilla)

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
	if gorillas.is_empty():
		match_active = false
		current_index = -1
		return

	# Ensure index in range
	if current_index < 0 or current_index >= gorillas.size():
		current_index = 0

	var loops: int = 0
	while loops < gorillas.size():
		var g: Gorilla = gorillas[current_index] as Gorilla
		if g.is_alive:
			emit_signal("turn_started", g)
			return
		current_index = (current_index + 1) % gorillas.size()
		loops += 1

	# If we get here, nobody is alive
	match_active = false
	current_index = -1

func end_turn() -> void:
	if not match_active:
		return
	if gorillas.is_empty():
		match_active = false
		current_index = -1
		return

	var g: Gorilla = gorillas[current_index] as Gorilla
	emit_signal("turn_ended", g)

	current_index = (current_index + 1) % gorillas.size()
	_start_alive_turn()

func current_gorilla() -> Gorilla:
	if not match_active:
		return null
	if current_index < 0 or current_index >= gorillas.size():
		return null
	return gorillas[current_index] as Gorilla
