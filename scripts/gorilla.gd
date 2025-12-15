extends CharacterBody3D
class_name Gorilla

signal died

var is_alive: bool = true
var health: int = 1

var yaw: float = 0.0
var pitch: float = deg_to_rad(45.0)

@onready var visuals: Node3D = $Visuals
@onready var anim_player: AnimationPlayer = $Visuals/bear/AnimationPlayer
@onready var throw_origin: Marker3D = $ThrowOrigin
@onready var aim_pivot: Node3D = $AimPivot
@onready var body_mesh: MeshInstance3D = $BodyMesh

func _process(_delta: float) -> void:
	if is_alive:
		_update_aim_visual()

func _update_aim_visual() -> void:
	# Keep pivot at throw origin
	aim_pivot.global_transform.origin = throw_origin.global_transform.origin

	# Use the same direction math we use for firing
	var dir: Vector3 = get_aim_direction()
	aim_pivot.look_at(aim_pivot.global_transform.origin + dir, Vector3.UP)

func get_aim_direction() -> Vector3:
	# Yaw: rotate around global UP
	var yaw_basis := Basis(Vector3.UP, yaw)
	var forward := yaw_basis * Vector3.FORWARD       # starts as (0, 0, -1) then yawed
	# Local right for this yaw
	var right := yaw_basis * Vector3.RIGHT
	# Pitch: rotate forward around local right
	var dir := forward.rotated(right, pitch)
	return dir.normalized()

func set_turn_active(active: bool) -> void:
	if not is_alive:
		return
	if active:
		_play_loop("Idle")
	else:
		# Pause when not active (your spec: idle only on that gorilla’s turn)
		if anim_player and anim_player.is_playing():
			anim_player.pause()

func play_attack() -> void:
	if not is_alive:
		return
	_play_once("Attack")

func play_death() -> void:
	_play_once("Death")

func _play_loop(name: String) -> void:
	if anim_player and anim_player.has_animation(name):
		anim_player.play(name)
		anim_player.speed_scale = 1.0

func _play_once(name: String) -> void:
	if anim_player and anim_player.has_animation(name):
		anim_player.play(name)
		anim_player.speed_scale = 1.0

func set_color(color: Color) -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy = 1.5
	body_mesh.set_surface_override_material(0, mat)

func apply_damage(amount: int) -> void:
	if not is_alive:
		return
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	if not is_alive:
		return
	is_alive = false
	play_death()
	emit_signal("died")
