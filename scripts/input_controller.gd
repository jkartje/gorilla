extends Node

@onready var turn_manager: TurnManager = $"../TurnManager"
@onready var hud: Node = $"../HUD"
@onready var camera: Camera3D = $"../MainCamera"

var charge: float = 0.0
var max_charge: float = 25.0

func _process(delta: float) -> void:
	var gorilla: Gorilla = turn_manager.current_gorilla()
	if gorilla == null:
		_update_hud(null)
		return

	if not gorilla.is_alive:
		_update_hud(gorilla)
		return

	# Aim - yaw (tank-style)
	if Input.is_action_pressed("ui_left"):
		gorilla.yaw += delta * 1.2
	elif Input.is_action_pressed("ui_right"):
		gorilla.yaw -= delta * 1.2

	# Aim - pitch
	if Input.is_action_pressed("ui_up"):
		gorilla.pitch = clamp(gorilla.pitch + delta * 0.8, deg_to_rad(10), deg_to_rad(80))
	elif Input.is_action_pressed("ui_down"):
		gorilla.pitch = clamp(gorilla.pitch - delta * 0.8, deg_to_rad(10), deg_to_rad(80))

	# Charge + throw
	if Input.is_action_pressed("accept"):
		charge = clamp(charge + delta * 20.0, 0.0, max_charge)
	elif Input.is_action_just_released("accept"):
		_fire_banana(gorilla)
		charge = 0.0
		turn_manager.end_turn()  # 🔁 advance to next gorilla

	_update_camera(gorilla)
	_update_hud(gorilla)

func _fire_banana(gorilla: Gorilla) -> void:
	if charge <= 0.0:
		return

	var proj_scene: PackedScene = load("res://scenes/BananaProjectile.tscn")
	var p: RigidBody3D = proj_scene.instantiate() as RigidBody3D
	get_tree().current_scene.add_child(p)

	var origin: Vector3 = gorilla.throw_origin.global_transform.origin
	var dir: Vector3 = gorilla.get_aim_direction()

	p.launch(origin, dir * charge)

func _update_camera(gorilla: Gorilla) -> void:
	# Simple follow: position camera behind and above the active gorilla
	var target: Vector3 = gorilla.global_transform.origin
	var offset: Vector3 = Vector3(0, 8, 16)
	camera.global_transform.origin = target + offset
	camera.look_at(target, Vector3.UP)

func _update_hud(gorilla: Gorilla) -> void:
	var text := "GORILLA TURN DEBUG\n"

	if gorilla:
		text += "Current gorilla: %s\n" % [gorilla.get_instance_id()]
		text += "Alive: %s\n" % (str(gorilla.is_alive))
		text += "Yaw: %.1f deg\n" % rad_to_deg(gorilla.yaw)
		text += "Pitch: %.1f deg\n" % rad_to_deg(gorilla.pitch)
	else:
		text += "No active gorilla\n"

	text += "Charge: %.1f\n" % charge

	# Optionally show how many gorillas are in the match
	var count: int = turn_manager.gorillas.size()
	text += "Total gorillas: %d\n" % count

	var hud_script = hud
	if "last_explosion_pos" in hud_script:
		var last_pos: Vector3 = hud_script.last_explosion_pos
		text += "Last explosion pos: (%.2f, %.2f, %.2f)\n" % [last_pos.x, last_pos.y, last_pos.z]

	hud.call("update_debug", text)
