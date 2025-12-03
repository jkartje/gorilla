extends Node

@onready var hud: Node = $"../HUD"

const GORILLA_SCENE: PackedScene = preload("res://scenes/Gorilla.tscn")

const MAP_HALF_SIZE: float = 100.0
const SPAWN_MARGIN: float = 10.0

var gorillas: Array[Node3D] = []
var player_gorilla: Node3D = null

# Configurable number of gorillas (including player)
var num_gorillas: int = 4

# Spawn zones (XZ rectangles) in world space for 200x200 map
var spawn_zones: Array[Dictionary] = [
	{ "min": Vector2(-MAP_HALF_SIZE + SPAWN_MARGIN, -MAP_HALF_SIZE + SPAWN_MARGIN),
	  "max": Vector2(-SPAWN_MARGIN, -SPAWN_MARGIN) },

	{ "min": Vector2(SPAWN_MARGIN, -MAP_HALF_SIZE + SPAWN_MARGIN),
	  "max": Vector2(MAP_HALF_SIZE - SPAWN_MARGIN, -SPAWN_MARGIN) },

	{ "min": Vector2(-MAP_HALF_SIZE + SPAWN_MARGIN, SPAWN_MARGIN),
	  "max": Vector2(-SPAWN_MARGIN, MAP_HALF_SIZE - SPAWN_MARGIN) },

	{ "min": Vector2(SPAWN_MARGIN, SPAWN_MARGIN),
	  "max": Vector2(MAP_HALF_SIZE - SPAWN_MARGIN, MAP_HALF_SIZE - SPAWN_MARGIN) },
]

# Distinct colors to rotate through
var gorilla_colors: Array[Color] = [
	Color(1, 0, 0),   # red
	Color(0, 1, 0),   # green
	Color(0, 0, 1),   # blue
	Color(1, 1, 0),   # yellow
	Color(1, 0, 1),   # magenta
	Color(0, 1, 1),   # cyan
]

func _ready() -> void:
	# Defer so parent (Main) finishes creating terrain before we raycast
	call_deferred("spawn_gorillas")

func spawn_gorillas() -> void:
	gorillas.clear()
	player_gorilla = null

	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()

	var main_root := get_parent() as Node3D
	if main_root == null:
		push_error("GameState: parent is not a Node3D")
		return

	var total: int = min(num_gorillas, spawn_zones.size())

	for i in range(total):
		var g := GORILLA_SCENE.instantiate() as Node3D

		var zone: Dictionary = spawn_zones[i]
		var spawn_pos: Vector3 = _compute_spawn_position(zone, rng, main_root)
		g.transform.origin = spawn_pos

		main_root.add_child(g)

		var color: Color = gorilla_colors[i % gorilla_colors.size()]
		g.call("set_color", color)

		gorillas.append(g)

	if gorillas.size() > 0:
		player_gorilla = gorillas[0]

func _compute_spawn_position(zone: Dictionary, rng: RandomNumberGenerator, main_root: Node3D) -> Vector3:
	var min_v: Vector2 = zone["min"]
	var max_v: Vector2 = zone["max"]

	var x: float = rng.randf_range(min_v.x, max_v.x)
	var z: float = rng.randf_range(min_v.y, max_v.y)

	var from: Vector3 = Vector3(x, 40.0, z)
	var to: Vector3 = Vector3(x, -40.0, z)

	var space_state: PhysicsDirectSpaceState3D = main_root.get_world_3d().direct_space_state

	var params: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	params.from = from
	params.to = to
	params.collide_with_areas = false
	params.collide_with_bodies = true

	var result: Dictionary = space_state.intersect_ray(params)

	var y: float = 1.0
	if result:
		var hit_pos: Vector3 = result["position"]
		y = hit_pos.y + 1.0

	return Vector3(x, y, z)

func get_player_gorilla() -> Node3D:
	return player_gorilla

func report_explosion(pos: Vector3) -> void:
	hud.call("set_last_explosion_position", pos)
