extends Node3D
class_name CameraRig

@onready var camera: Camera3D = $MainCamera

enum FollowMode { ACTOR, PROJECTILE, FREE }

var mode: int = FollowMode.ACTOR
var actor: Node3D = null
var projectile: Node3D = null
var free_center: Vector3 = Vector3.ZERO

# Camera orbit parameters
var yaw: float = 0.0
var pitch: float = deg_to_rad(30.0)   # slightly above horizon
var distance: float = 12.0            # third-person-ish distance

const MIN_PITCH: float = deg_to_rad(10.0)   # no flat / under-level views
const MAX_PITCH: float = deg_to_rad(70.0)   # no straight-down
const MOUSE_SENS: float = 0.003
const MIN_CAMERA_Y: float = 0.5             # never below ground plane
const ABOVE_CENTER_Y: float = 2.5           # always this much above actor/explosion center

func _ready() -> void:
	# Capture mouse so we can rotate endlessly without edge issues
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func set_target(new_target: Node3D) -> void:
	actor = new_target
	if actor == null:
		return

	mode = FollowMode.ACTOR

	# Start by looking from this actor toward level center (0,0,0)
	var level_center: Vector3 = Vector3.ZERO
	var to_center: Vector3 = level_center - actor.global_transform.origin

	yaw = atan2(to_center.x, to_center.z)
	pitch = deg_to_rad(30.0)

	_update_transform()

func follow_projectile(p: Node3D) -> void:
	projectile = p
	mode = FollowMode.PROJECTILE

func focus_actor_mode() -> void:
	mode = FollowMode.ACTOR
	projectile = null
	_update_transform()

func focus_point(point: Vector3) -> void:
	# Freeze camera orbit around a specific world point (explosion)
	free_center = point
	mode = FollowMode.FREE
	_update_transform()

func _unhandled_input(event: InputEvent) -> void:
	# Only react to mouse if we have something to follow or a free center
	if actor == null and projectile == null and mode != FollowMode.FREE:
		return

	if event is InputEventMouseMotion:
		var m := event as InputEventMouseMotion
		# Horizontal orbit
		yaw -= m.relative.x * MOUSE_SENS
		# Vertical orbit, clamped so we don't go below level or overhead
		pitch = clamp(pitch - m.relative.y * MOUSE_SENS, MIN_PITCH, MAX_PITCH)

func _process(_delta: float) -> void:
	_update_transform()

func _update_transform() -> void:
	var center: Vector3

	match mode:
		FollowMode.PROJECTILE:
			if projectile != null:
				center = projectile.global_transform.origin
			elif actor != null:
				center = actor.global_transform.origin
			else:
				return
		FollowMode.FREE:
			center = free_center
		FollowMode.ACTOR:
			if actor == null:
				return
			center = actor.global_transform.origin

	# Always look a bit above the center (head/explosion height)
	center.y += ABOVE_CENTER_Y

	# Spherical coordinates → direction vector
	var dir := Vector3(
		cos(pitch) * sin(yaw),
		sin(pitch),
		cos(pitch) * cos(yaw)
	).normalized()

	# Place camera behind the direction vector at 'distance'
	var new_pos: Vector3 = center - dir * distance

	# Do not let camera go below ground or too far below the look center
	if new_pos.y < MIN_CAMERA_Y:
		new_pos.y = MIN_CAMERA_Y
	if new_pos.y < center.y - 1.0:
		new_pos.y = center.y - 1.0

	global_transform.origin = new_pos
	look_at(center, Vector3.UP)
