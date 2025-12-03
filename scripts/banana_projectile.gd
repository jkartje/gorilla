extends RigidBody3D

var exploded: bool = false
const EXPLOSION_SCENE := preload("res://scenes/DebugExplosion.tscn")

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4

func launch(origin: Vector3, velocity: Vector3) -> void:
	global_transform.origin = origin
	linear_velocity = velocity

func _physics_process(_delta: float) -> void:
	# Safety: if we fall way out of the world, clean up
	if global_transform.origin.y < -50.0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	explode()

func explode() -> void:
	if exploded:
		return
	exploded = true

	# Spawn visible debug explosion at impact point
	_spawn_debug_explosion()

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

	queue_free()

func _spawn_debug_explosion() -> void:
	var explosion = EXPLOSION_SCENE.instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.global_transform.origin = global_transform.origin

	# Report to HUD via GameState
	var game_state = get_tree().current_scene.get_node("GameState")
	if game_state:
		game_state.report_explosion(global_transform.origin)
