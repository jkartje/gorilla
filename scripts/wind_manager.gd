extends Node
class_name WindManager

signal wind_changed(direction: Vector3, speed: float)

@export var min_speed: float = 0.0
@export var max_speed: float = 4.0
@export var altitude_start: float = 5.0      # meters above ground where wind starts increasing
@export var altitude_end: float = 50.0       # height where wind reaches max strength
@export var max_altitude_multiplier: float = 1.2


# Primary tuning knob: how hard wind pushes projectiles.
@export var strength: float = 5.0

var _direction: Vector3 = Vector3.RIGHT
var _speed: float = 0.0

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	randomize_wind()

func randomize_wind() -> void:
	var angle := rng.randf_range(0.0, TAU)
	_direction = Vector3(cos(angle), 0.0, sin(angle)).normalized()
	_speed = rng.randf_range(min_speed, max_speed)
	emit_signal("wind_changed", _direction, _speed)

func get_wind_force_at_height(y: float) -> Vector3:
	var t := inverse_lerp(altitude_start, altitude_end, y)
	t = clamp(t, 0.0, 1.0)
	var altitude_multiplier: float = lerp(1.0, max_altitude_multiplier, t)
	return (_direction * _speed) * strength * altitude_multiplier


func get_wind_vector() -> Vector3:
	return _direction * _speed
