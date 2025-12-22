extends CharacterBody3D
class_name Gorilla

signal died
signal throw_released(origin: Vector3, direction: Vector3, charge: float)

var is_alive: bool = true
var health: int = 1

var yaw: float = 0.0
var pitch: float = deg_to_rad(45.0)

# Animation library that contains the editable clips
# Expected names:
#   Local_Anims/Idle
#   Local_Anims/Attack
#   Local_Anims/Death
const ANIM_LIB: String = "Local_Anims"

@onready var visuals: Node3D = $Visuals
@onready var anim_player: AnimationPlayer = $Visuals/bear/AnimationPlayer
@onready var throw_origin: Marker3D = $ThrowOrigin
@onready var aim_pivot: Node3D = $AimPivot
@onready var body_mesh: MeshInstance3D = $BodyMesh

# Cached throw data (set on input release, consumed by animation event)
var _pending_throw: bool = false
var _pending_origin: Vector3 = Vector3.ZERO
var _pending_dir: Vector3 = Vector3.FORWARD
var _pending_charge: float = 0.0


func _process(_delta: float) -> void:
	if is_alive:
		_update_aim_visual()


func _update_aim_visual() -> void:
	# Keep pivot at throw origin
	aim_pivot.global_transform.origin = throw_origin.global_transform.origin

	# Use the same direction math as the projectile launch
	var dir: Vector3 = get_aim_direction()
	aim_pivot.look_at(aim_pivot.global_transform.origin + dir, Vector3.UP)


func get_aim_direction() -> Vector3:
	# Yaw: rotate around global UP
	var yaw_basis := Basis(Vector3.UP, yaw)
	var forward := yaw_basis * Vector3.FORWARD
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
		# Spec: only animate the active gorilla
		if anim_player and anim_player.is_playing():
			anim_player.pause()


# Called by InputController on button release.
# Starts Attack immediately; actual launch happens when the animation hits its event key.
func request_throw(charge: float) -> void:
	if not is_alive:
		return
	if charge <= 0.0:
		return

	_pending_throw = true
	_pending_charge = charge
	_pending_origin = throw_origin.global_transform.origin
	_pending_dir = get_aim_direction()

	_play_once("Attack")


# Called by Call Method track inside Local_Anims/Attack
# This is the exact visual release moment.
func anim_throw_release() -> void:
	if not _pending_throw:
		return

	_pending_throw = false
	emit_signal("throw_released", _pending_origin, _pending_dir, _pending_charge)


func play_death() -> void:
	_play_once("Death")


func _play_loop(name: String) -> void:
	if not anim_player:
		return

	var local_name := "%s/%s" % [ANIM_LIB, name]
	if anim_player.has_animation(local_name):
		anim_player.play(local_name)
		anim_player.speed_scale = 1.0
		return

	# Fallback (safety)
	if anim_player.has_animation(name):
		anim_player.play(name)
		anim_player.speed_scale = 1.0


func _play_once(name: String) -> void:
	if not anim_player:
		return

	var local_name := "%s/%s" % [ANIM_LIB, name]
	if anim_player.has_animation(local_name):
		anim_player.play(local_name)
		anim_player.speed_scale = 1.0
		return

	# Fallback (safety)
	if anim_player.has_animation(name):
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
