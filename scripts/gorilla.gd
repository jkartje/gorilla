extends CharacterBody3D
class_name Gorilla

signal died

var is_alive: bool = true
var health: int = 1

var yaw: float = 0.0
var pitch: float = deg_to_rad(45.0)

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
	is_alive = false
	hide()
	emit_signal("died")
