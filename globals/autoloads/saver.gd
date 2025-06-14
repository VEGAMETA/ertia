extends Node

const MAX_QUICKSAVES : int = 10

@export_storage var base_directory : String = "user://"
@export_storage var save_directory : String = base_directory + "saves/"

var temp_directory : String = save_directory + "tmp/"
var temp_filetype : String = ".tmp"
var save_filetype : String = ".sav"
var backup_save_filetype : String = ".backup"


enum SaveType {
	ALL,
	QUICKSAVE,
	AUTOSAVE,
	MANUAL,
	UNKNOWN
}

signal save_init
signal save_finish

func get_prefix_by_type(type:SaveType) -> String:
	match type:
		SaveType.QUICKSAVE: return "quicksave_"
		SaveType.AUTOSAVE: return "auto_"
		SaveType.MANUAL: return "slot_"
		_: return "_"

func create_if_not_exists() -> bool:
	var dir : DirAccess = DirAccess.open(base_directory)
	var result : Error
	result = dir.make_dir(save_directory)
	if result and result != ERR_ALREADY_EXISTS:
		push_error("Unable to create save directory: %s" % save_directory)
		return false
	result = dir.make_dir(temp_directory)
	if result and result != ERR_ALREADY_EXISTS: 
		push_error("Unable to create save directory: %s" % temp_directory)
		return false
	return true

func get_savefiles() -> Array[String]:
	if not create_if_not_exists(): return []
	var dir : DirAccess = DirAccess.open(save_directory)
	if dir == null:
		push_error("Unable to access directory: %s" % save_directory)
		return []
	var files : Array[String]
	files.append_array(dir.get_files())
	return files

func get_savefiles_by_type(type:SaveType) -> Array[String]:
	var prefix : String = get_prefix_by_type(type)
	if not type: return get_savefiles()
	return get_savefiles().filter(func (file_name:String): return file_name.begins_with(prefix) and file_name.ends_with(save_filetype))

func get_next_index(type:SaveType) -> int:
	var prefix : String = get_prefix_by_type(type)
	var i : int = 0
	var used_indices : Dictionary[int, bool] = {}
	for file_name in get_savefiles_by_type(type):
		var number_str = file_name.trim_prefix(prefix).trim_suffix(save_filetype)
		if not number_str.is_valid_int(): continue
		used_indices[int(number_str)] = true
	while true:
		if not used_indices.has(i): return i
		i += 1
	return i

func fetch_metadata(type:SaveType) -> SaveMetadata:
	var metadata = SaveMetadata.new()
	metadata.setup(
		Time.get_unix_time_from_system(),
		get_viewport().get_texture().get_image(),
		type, 
		get_tree_string()
	)
	return metadata

func get_new_save_file(type:SaveType) -> String:
	var save_file : String = save_directory
	var save_type : String = get_prefix_by_type(type)
	var index : int = get_next_index(type)
	if index == -1: return ""
	return save_file + save_type + str(index) + save_filetype

func get_metadata(save_path:String) -> Dictionary[String, SaveMetadata]:
	var file : FileAccess = FileAccess.open(save_path, FileAccess.READ)
	if file == null: 
		push_error("Failed to open save file.")
		return {}
	var temp_metadata : String = temp_directory + UUID.v4() + temp_filetype  + ".res"
	var metadata_scene : PackedByteArray = file.get_buffer(file.get_32())
	file.close()
	metadata_scene = metadata_scene.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP)
	
	file = FileAccess.open(temp_metadata, FileAccess.WRITE)
	file.store_buffer(metadata_scene)
	file.close()
	
	var metadata: SaveMetadata = ResourceLoader.load(temp_metadata)
	
	DirAccess.remove_absolute(temp_metadata)
	if metadata == null or metadata is not SaveMetadata:
		push_error("Failed to load metadata.")
		return {}
	return {save_path: metadata}

func get_saves(type:SaveType=SaveType.ALL) -> Array:
	var saves : Array = get_savefiles_by_type(type).map(func (path): return save_directory + path)
	saves = saves.map(get_metadata)
	if not saves: return []
	saves.sort_custom(func(a:Dictionary, b:Dictionary): return a.values()[0].time > b.values()[0].time)
	return saves

func save(metadata:SaveMetadata, scene:Node=get_tree().current_scene) -> void:
	save_init.emit()
	_save(metadata, scene)
	save_finish.emit()

func _save(metadata:SaveMetadata, scene:Node) -> void:
	var packed : PackedScene = PackedScene.new()
	var temp_scene : String = temp_directory + UUID.v4() + temp_filetype + ".tscn"
	var temp_metadata : String = temp_directory + UUID.v4() + temp_filetype + ".res"
	var save_file : String = get_new_save_file(metadata.type)
	if not save_file: return push_error("Failed to initialize save filepath")
	var result : Error
	var file : FileAccess
	var final_file: FileAccess
	var scene_data : PackedByteArray
	var metadata_data : PackedByteArray
	
	packed.pack(scene)
	
	result = ResourceSaver.save(packed, temp_scene)
	if result != OK: return push_error("Failed to save temporary scene.")
	file = FileAccess.open(temp_scene, FileAccess.READ)
	scene_data = file.get_buffer(file.get_length())
	file.close()
	scene_data = scene_data.compress(FileAccess.COMPRESSION_GZIP)
	
	result = ResourceSaver.save(metadata, temp_metadata)
	if result != OK: return push_error("Failed to save temporary metadata.")
	file = FileAccess.open(temp_metadata, FileAccess.READ)
	metadata_data = file.get_buffer(file.get_length())
	file.close()
	metadata_data = metadata_data.compress(FileAccess.COMPRESSION_GZIP)
	
	final_file = FileAccess.open(save_file, FileAccess.WRITE)
	final_file.store_32(metadata_data.size())
	final_file.store_buffer(metadata_data)
	final_file.store_buffer(scene_data)
	final_file.close()
	
	DirAccess.remove_absolute(temp_scene)
	DirAccess.remove_absolute(temp_metadata)

func load_save(save_path:String) -> void:
	var file : FileAccess = FileAccess.open(save_path, FileAccess.READ)
	if file == null: return push_error("Failed to open save file.")
	var temp_scene : String = temp_directory + UUID.v4() + temp_filetype + ".tscn"
	var garbage : int = file.get_32()
	file.get_buffer(garbage)
	var saved_scene : PackedByteArray = file.get_buffer(file.get_length() - garbage - 4)
	file.close()
	saved_scene = saved_scene.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP)
	
	file = FileAccess.open(temp_scene, FileAccess.WRITE)
	file.store_buffer(saved_scene)
	file.close()
	
	var scene : Resource = ResourceLoader.load(temp_scene)
	if scene == null: return push_error("Failed to load scene.")
	get_tree().call_deferred("change_scene_to_file", temp_scene)
	DirAccess.remove_absolute(temp_scene)

func load_last_save(type:SaveType) -> void:
	var files : Array = get_saves(type)
	if not files: return
	return load_save(files[0].keys()[0])

func quickload() -> void:
	load_last_save(SaveType.QUICKSAVE)

func quicksave() -> void:
	save(fetch_metadata(SaveType.QUICKSAVE))
	erase_quicksaves()

func erase_quicksaves() -> void:
	var files : Array = get_saves(SaveType.QUICKSAVE)
	if not files: return
	if files.size() <= 10: return
	DirAccess.remove_absolute(files[-1].keys()[0])
