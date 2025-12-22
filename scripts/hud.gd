extends CanvasLayer

@onready var debug_label: Label = $DebugStack/DebugLabel
@onready var wind_label: Label = $DebugStack/WindWidget/WindLabel


var last_explosion_pos: Vector3 = Vector3.ZERO
var wind_dir: Vector3 = Vector3.ZERO
var wind_speed: float = 0.0

func update_debug(text: String) -> void:
	debug_label.text = text

func set_last_explosion_position(pos: Vector3) -> void:
	last_explosion_pos = pos
	
func set_wind(dir: Vector3, speed: float) -> void:
	var deg := rad_to_deg(atan2(dir.z, dir.x))
	if deg < 0.0:
		deg += 360.0
	wind_label.text = "Wind: %.1f @ %.0f°" % [speed, deg]
