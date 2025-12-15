# res://scripts/characters/gorilla_character.gd
extends CharacterBody3D

@export var model_instance_name: NodePath = NodePath("Visuals/bear")
@export var idle_anim: StringName = &"Idle"
@export var attack_anim: StringName = &"Attack"
@export var death_anim: StringName = &"Death"

@onready var _model_root: Node = get_node_or_null(model_instance_name)
@onready var _anim: AnimationPlayer = _get_anim_player()

func _ready() -> void:
	play_idle()

func _get_anim_player() -> AnimationPlayer:
	if _model_root == null:
		push_warning("gorilla_character: model root not found at %s" % [model_instance_name])
		return null

	var ap: AnimationPlayer = _model_root.get_node_or_null("AnimationPlayer") as AnimationPlayer
	if ap != null:
		return ap

	var found: Array[Node] = _model_root.find_children("*", "AnimationPlayer", true, false)
	if found.size() > 0:
		return found[0] as AnimationPlayer

	push_warning("gorilla_character: AnimationPlayer not found under model root")
	return null

func play_idle() -> void:
	if _anim != null and _anim.has_animation(idle_anim):
		_anim.play(idle_anim)

func play_attack() -> void:
	if _anim != null and _anim.has_animation(attack_anim):
		_anim.play(attack_anim)

func play_death() -> void:
	if _anim != null and _anim.has_animation(death_anim):
		_anim.play(death_anim)

# Called by GameState via: g.call("set_color", color)
func set_color(color: Color) -> void:
	if _model_root == null:
		push_warning("gorilla_character.set_color: model root missing; cannot apply color.")
		return

	var meshes: Array[Node] = _model_root.find_children("*", "MeshInstance3D", true, false)
	for n in meshes:
		var mi := n as MeshInstance3D
		if mi == null:
			continue

		var mesh := mi.mesh
		if mesh == null:
			continue

		var surface_count := mesh.get_surface_count()
		for s in range(surface_count):
			var mat: Material = mi.get_active_material(s)
			if mat == null:
				continue

			var mat_dup: Material = mat.duplicate(true) as Material
			if mat_dup is StandardMaterial3D:
				(mat_dup as StandardMaterial3D).albedo_color = color
			elif mat_dup is BaseMaterial3D:
				# Covers other built-in 3D material types that still have albedo_color
				(mat_dup as BaseMaterial3D).albedo_color = color
			# ShaderMaterial: we don't assume param names

			mi.set_surface_override_material(s, mat_dup)
