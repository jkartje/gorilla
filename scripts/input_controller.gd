extends Node

@onready var game_state = $"../GameState"
@onready var hud = $"../HUD"
@onready var camera = $"../MainCamera"

var charge: float = 0.0
var max_charge: float = 25.0

func _process(delta: float) -> void:
	var gorilla = game_state.get_player_gorilla()
	if gorilla == null or not gorilla.is_alive:
		_update_hud(null)
		return

		# Aim - yaw (tank-style: LEFT turns barrel left, RIGHT turns right)
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

	_update_hud(gorilla)

func _fire_banana(gorilla: Node) -> void:
	if charge <= 0.0:
		return

	var proj_scene: PackedScene = load("res://scenes/BananaProjectile.tscn")
	var p = proj_scene.instantiate()
	get_tree().current_scene.add_child(p)

	var origin: Vector3 = gorilla.throw_origin.global_transform.origin
	var dir: Vector3 = gorilla.get_aim_direction()

	p.launch(origin, dir * charge)


func _update_hud(gorilla: Node) -> void:
	var text := "GORILLA THROW DEBUG\n"

	if gorilla:
		text += "Alive: %s\n" % (str(gorilla.is_alive))
		text += "Yaw: %.1f deg\n" % rad_to_deg(gorilla.yaw)
		text += "Pitch: %.1f deg\n" % rad_to_deg(gorilla.pitch)
	else:
		text += "Alive: false or no player\n"
		text += "Yaw: -\n"
		text += "Pitch: -\n"

	text += "Charge: %.1f\n" % charge

	var hud_script = hud
	var last_pos: Vector3 = hud_script.last_explosion_pos
	text += "Last explosion pos: (%.2f, %.2f, %.2f)\n" % [last_pos.x, last_pos.y, last_pos.z]

	hud.update_debug(text)
