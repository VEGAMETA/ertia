class_name StrongGravityObject extends GravityObject

var shader : ShaderMaterial


func _ready() -> void:
	super()
	gravity_vector = -transform.basis.y
	var mesh := MeshInstance3D.new()
	mesh.mesh = SphereMesh.new()
	mesh.mesh.radius = 1.0
	mesh.mesh.height = 2.0
	shader = ShaderMaterial.new()
	shader.shader = load("uid://crknpdgmgvypv")
	mesh.mesh.surface_set_material(0, shader)
	shader.set_shader_parameter(&"gravity_vector", gravity_vector)
	add_child(mesh)


func _on_change_gravity(_new_gravity_vector: Vector3) -> void: return


func _integrate_forces(state:PhysicsDirectBodyState3D) -> void:
	super(state)
	gravity_vector = -transform.basis.y
	state.set_constant_force((gravity_vector - Gravity.gravity_vector) * Gravity.gravity)
	shader.set_shader_parameter(&"gravity_vector", gravity_vector)
