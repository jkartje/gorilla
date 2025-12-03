extends CanvasLayer

@onready var debug_label: Label = $DebugLabel

var last_explosion_pos: Vector3 = Vector3.ZERO

func update_debug(text: String) -> void:
	debug_label.text = text

func set_last_explosion_position(pos: Vector3) -> void:
	last_explosion_pos = pos
