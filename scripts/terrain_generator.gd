extends Node3D

const COLUMN_SCENE: PackedScene = preload("res://scenes/TerrainColumn.tscn")

const MAP_HALF_SIZE: float = 100.0      # 200x200 map from -100..100
const CELL_SIZE: float = 10.0           # each cell is 10x10 units
const GRID_SIZE: int = int((MAP_HALF_SIZE * 2.0) / CELL_SIZE)

# Height config
const HEIGHT_MIN: float = 2.0
const HEIGHT_MAX: float = 20.0
const HEIGHT_STEP: float = 4.0          # max change from neighbors


var heights: Array = []   # outer array of rows; inner arrays are plain Array[float], untyped to avoid nested generics

func _ready() -> void:
	_generate_heights()
	_build_columns()

func _generate_heights() -> void:
	heights.resize(GRID_SIZE)

	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()

	for x in range(GRID_SIZE):
		var row: Array = []

		for z in range(GRID_SIZE):
			var base: float = 0.0
			var count: int = 0

			if x > 0:
				base += float(heights[x - 1][z])
				count += 1
			if z > 0:
				base += float(row[z - 1])
				count += 1
			if x > 0 and z > 0:
				base += float(heights[x - 1][z - 1])
				count += 1

			if count > 0:
				base /= float(count)

			var delta: float = rng.randf_range(-HEIGHT_STEP, HEIGHT_STEP)
			var h: float = clamp(base + delta, HEIGHT_MIN, HEIGHT_MAX)

			row.append(h)

		heights[x] = row

func _build_columns() -> void:
	# starting world offset so cells are centered on the origin
	var start: float = -MAP_HALF_SIZE + CELL_SIZE * 0.5

	for x in range(GRID_SIZE):
		var row: Array = heights[x]
		for z in range(GRID_SIZE):
			var h: float = float(row[z])
			if h <= 0.1:
				continue  # skip almost-flat, leave base plane visible

			var column: Node3D = COLUMN_SCENE.instantiate() as Node3D

			var world_x: float = start + float(x) * CELL_SIZE
			var world_z: float = start + float(z) * CELL_SIZE

			# Root position at middle of the column vertically
			column.position = Vector3(world_x, h * 0.5, world_z)
			# Scale so top is at height h and footprint is CELL_SIZE
			column.scale = Vector3(CELL_SIZE, h, CELL_SIZE)

			add_child(column)
