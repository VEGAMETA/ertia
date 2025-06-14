@tool
class_name GravityArea3D extends Area3D

@export_flags("TOP", "BOTTOM", "LEFT", "RIGHT", "FRONT", "REAR", "ZERO")
var chosen_gravity : int = 2:
	set(value):
		_gravity_direction = GravityDirections.by_flag.get(value, GravityDirections.ZERO)
		gravity_direction = _gravity_direction.rotation_vector
	get: return _gravity_direction.flag

@export_flags("TOP", "BOTTOM", "LEFT", "RIGHT", "FRONT", "REAR", "ZERO")
var avalible_gravities: int = 63

@export
var shape_size : Vector3i = Vector3i.ONE:
	set(value):
		collision_shape.size = value
		mesh.size = value
	get: return collision_shape.size

@export var is_on : bool = true

var col := Color(0.5, 0.5, 0.5, 1.5)
var highlighter := Color(0.2, 0.2, 0.2, 0.5)
var highlighter_v3 := Vector3(0.2, 0.2, 0.1)
var _gravity_direction := GravityDirections.BOTTOM
var collision := CollisionShape3D.new()
var meshinstance := MeshInstance3D.new()
var collision_shape := BoxShape3D.new()
var mesh := BoxMesh.new()
var material := ShaderMaterial.new()
var shader_mat_holo := ShaderMaterial.new()
var shader := preload("res://static/shaders/area.gdshader") as Shader
var shader_holo := preload("res://static/shaders/holo.gdshader") as Shader
var highlighter_shader := preload("res://static/shaders/highlight.gdshader") as Shader
var generated_collision : CollisionShape3D = null
var generated_mesh : MeshInstance3D = null


func _ready():
	if is_on: initialize()


func initialize():
	gravity_space_override = Area3D.SPACE_OVERRIDE_REPLACE
	
	collision_layer = Globals.Collisions.GRAVITY_AREAS
	collision_mask = (
		Globals.Collisions.STATIC ||
		Globals.Collisions.PLAYER ||
		Globals.Collisions.DYNAMIC || 
		0
	)
	
	material.shader = shader
	set_holo()
	material.render_priority = 1
	var highlighter_material = ShaderMaterial.new()
	highlighter_material.shader = highlighter_shader
	material.next_pass.next_pass = highlighter_material
	
	if not self.get_child_count():
		collision.shape = collision_shape
		mesh.material = material
		meshinstance.mesh = mesh
		add_child(collision)
		add_child(meshinstance)
	else:
		generated_mesh.mesh.surface_set_material(0, material)
	#gravity_direction = GravityDirections.by_flag.get(chosen_gravity, GravityDirections.ZERO)
	set_color()



func set_holo() -> void:
	shader_mat_holo.shader = shader_holo
	shader_mat_holo.set_shader_parameter("line_color", col + highlighter)
	shader_mat_holo.set_shader_parameter("line_width", 0.002)
	shader_mat_holo.set_shader_parameter("line_blur", 0.4)
	shader_mat_holo.set_shader_parameter("straight_lines", false)
	shader_mat_holo.set_shader_parameter("line_speed", 0.003)
	shader_mat_holo.set_shader_parameter("interrupt_speed", 0.375)
	shader_mat_holo.set_shader_parameter("glow_color", col * 0.5 + highlighter)
	material.next_pass = shader_mat_holo


func set_color() -> void:
	col = _gravity_direction.color
	material.set_shader_parameter("col", _gravity_direction.rotation_vector + highlighter_v3)
	#material.set_shader_parameter("alpha", 0.1)
	shader_mat_holo.set_shader_parameter("line_color", col + highlighter)
	shader_mat_holo.set_shader_parameter("glow_color", col * 0.5 + highlighter)


func change_gravity(value: Vector3) -> void:
	_gravity_direction = GravityDirections.by_vector.get(value, GravityDirections.ZERO)
	gravity_direction = _gravity_direction.rotation_vector
	chosen_gravity = _gravity_direction.flag
	set_color()
