extends Node3D

@onready var turn_manager: TurnManager = $TurnManager
@onready var camera_rig: CameraRig = $CameraRig

func _ready() -> void:
	turn_manager.turn_started.connect(_on_turn_started)

func _on_turn_started(g: Gorilla) -> void:
	camera_rig.set_target(g)
