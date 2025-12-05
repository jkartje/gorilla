extends Node
class_name TurnManager

signal turn_started(gorilla: Gorilla)
signal turn_ended(gorilla: Gorilla)

var gorillas: Array = []          # will contain Gorilla instances
var current_index: int = -1
var match_active: bool = false

func start_match(gorilla_list: Array) -> void:
	# Accept any array, keep only Gorilla instances
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
	emit_signal("turn_started", gorillas[current_index] as Gorilla)

func end_turn() -> void:
	if not match_active:
		return
	if gorillas.is_empty():
		match_active = false
		current_index = -1
		return

	var g := gorillas[current_index] as Gorilla
	emit_signal("turn_ended", g)

	current_index = (current_index + 1) % gorillas.size()
	emit_signal("turn_started", gorillas[current_index] as Gorilla)

func current_gorilla() -> Gorilla:
	if not match_active:
		return null
	if current_index < 0 or current_index >= gorillas.size():
		return null
	return gorillas[current_index] as Gorilla
