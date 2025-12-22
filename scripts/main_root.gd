extends Node3D

@onready var turn_manager: TurnManager = $TurnManager
@onready var camera_rig: CameraRig = $CameraRig
@onready var wind_manager: WindManager = $WindManager
@onready var hud: Node = $HUD

func _ready() -> void:
	turn_manager.turn_started.connect(_on_turn_started)

	# HUD listens for wind changes (we'll add HUD method in Step 4)
	wind_manager.wind_changed.connect(_on_wind_changed)

func _on_turn_started(g: Gorilla) -> void:
	camera_rig.set_target(g)
	wind_manager.randomize_wind()

func _on_wind_changed(dir: Vector3, speed: float) -> void:
	# HUD method we'll create: set_wind(dir, speed)
	hud.call("set_wind", dir, speed)
