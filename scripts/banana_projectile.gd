extends RigidBody3D

signal resolved(position: Vector3)

const EXPLOSION_SCENE: PackedScene = preload("res://scenes/DebugExplosion.tscn")

var resolved_flag: bool = false

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4

func launch(origin: Vector3, velocity: Vector3) -> void:
	global_transform.origin = origin
	linear_velocity = velocity

func _physics_process(_delta: float) -> void:
	# If we fall too far, treat as out-of-bounds resolution
	if not resolved_flag and global_transform.origin.y < -50.0:
		_resolve(false)

func _on_body_entered(_body: Node) -> void:
	# Impact with anything → explode and resolve
	explode()

func explode() -> void:
	if resolved_flag:
		return

	# Spawn a visible explosion at the impact point, slightly above surface
	var explosion := EXPLOSION_SCENE.instantiate()
	get_tree().current_scene.add_child(explosion)
	var pos: Vector3 = global_transform.origin
	pos.y += 0.5
	explosion.global_transform.origin = pos

	# Deal damage in a radius
	var radius: float = 3.0

	var shape := SphereShape3D.new()
	shape.radius = radius

	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = shape
	params.transform = Transform3D(Basis(), global_transform.origin)
	params.collision_mask = 1  # gorilla layer

	var space_state := get_world_3d().direct_space_state
	var results: Array = space_state.intersect_shape(params)

	for result in results:
		var collider := result["collider"] as Node
		if collider and collider.has_method("apply_damage"):
			collider.apply_damage(1)

	_resolve(true)

func _resolve(_from_explosion: bool) -> void:
	if resolved_flag:
		return
	resolved_flag = true

	emit_signal("resolved", global_transform.origin)
	queue_free()
