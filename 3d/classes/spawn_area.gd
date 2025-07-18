@tool
class_name SpawnArea3D extends Area3D

@export_file("*.tscn")
var scene : String = "uid://diyb5sbluyv0b"

func spawn() -> void:
	if not owner: return push_error("SpawnArea3D must have owner")
	var result : Error = _try_spawn() 
	if result: push_error("Cannot spawn!" + error_string(result))

func _try_spawn() -> Error:
	if not FileAccess.file_exists(scene): return ERR_FILE_BAD_PATH
	var loaded_scene : Resource = load(scene)
	if loaded_scene is not PackedScene: return ERR_CANT_ACQUIRE_RESOURCE
	if not (loaded_scene as PackedScene).can_instantiate(): 
		return ERR_CANT_CREATE
	var instance : Node = (loaded_scene as PackedScene).instantiate()
	if instance is not Node3D: return ERR_INVALID_DECLARATION
	owner.add_child(instance)
	instance.owner = owner
	return OK
	
