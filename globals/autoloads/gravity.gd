extends Node

var PS3D := PhysicsServer3D
var space : RID
var gravity : float
var gravity_vector : Vector3

signal change_gravity(gravity_vector)

func _ready() -> void:
	space = get_viewport().find_world_3d().space
	gravity = get_gravity()
	gravity_vector = get_gravity_vector()

func change_gravity_vector(new_gravity_vector) -> void:
	gravity_vector = new_gravity_vector
	PS3D.area_set_param(space, PS3D.AREA_PARAM_GRAVITY_VECTOR, new_gravity_vector)
	change_gravity.emit(new_gravity_vector)

func get_gravity_vector() -> Vector3:
	return PS3D.area_get_param(space, PS3D.AREA_PARAM_GRAVITY_VECTOR)
	
func get_gravity() -> float:
	return PS3D.area_get_param(space, PS3D.AREA_PARAM_GRAVITY)
