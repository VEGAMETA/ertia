class_name BaseGravity extends Node

var gravity_vector : Vector3:
	set(value): ProjectSettings.set_setting("physics/3d/default_gravity_vector", value)
	get: return ProjectSettings.get_setting("physics/3d/default_gravity_vector")

var gravity_value : Vector3:
	set(value): ProjectSettings.set_setting("physics/3d/default_gravity", value)
	get: return ProjectSettings.get_setting("physics/3d/default_gravity")
