extends Node

var ip_regex := RegEx.new()
var map_path : String = "res://3d/maps/"


func _ready() -> void:
	ip_regex.compile(r"^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$")


func validate_ip(ip:String) -> String:
	return ip if ip_regex.search(ip) else ""


func get_subclasses(base: GDScript) -> Array[String]:
	var subs : Array[String] = []
	for cls:Dictionary in ProjectSettings.get_global_class_list():
		if cls.get("base") != base.get_global_name(): continue
		subs.append(cls.get("class"))
	return subs


func get_class_from_string(name_: String) -> GDScript:
	for info:Dictionary in ProjectSettings.get_global_class_list():
		if info.get("class") != name_: continue
		var scr : GDScript = load(info["path"]) as GDScript
		return scr
	return null


func get_maps() -> Array:
	var map_files := Array(DirAccess.get_files_at(map_path))
	for dir : String in DirAccess.get_directories_at(map_path):
		map_files.append_array(Array(DirAccess.get_files_at(map_path + dir)))
	map_files = map_files.filter(
		func (path:String) -> bool: 
			return path.contains(".tscn") and not path.ends_with(".tmp")
	)
	map_files = map_files.map(func (path:String) -> String: return path.trim_suffix(".remap").trim_suffix(".tscn"))
	return map_files


func _load_deferred(map:String) -> void:
	if map == "":
		return Console.printerr("Cannot find the map", ERR_FILE_BAD_PATH)
	var scene := ResourceLoader.load(map)
	if not(scene is PackedScene):
		return Console.printerr("Cannot load the map", ERR_FILE_BAD_PATH)
	var node := (scene as PackedScene).instantiate()
	if get_tree().change_scene_to_node(node):
		Console.printerr("Cannot instantiate the map", ERR_CANT_CREATE)


@rpc("authority", "call_remote")
func load_map(map:String) -> String:
	var full_map_path : String = get_full_map_name(map)
	_load_deferred.call_deferred(full_map_path)
	return full_map_path


func get_full_map_name(map:String) -> String:
	var filename : String = map + (".tscn" if not map.contains(".tscn") else "")
	filename = filename.trim_suffix(".remap")
	print(filename)
	return find_map_path(filename)


func find_map_path(filename:String, root_dir:String = map_path) -> String:
	if filename == "":
		return ""
	var dir := DirAccess.open(root_dir)
	if dir == null:
		return ""
	var fullpath := root_dir.path_join(filename)
	var filename_remap := filename + ".remap"
	var files := dir.get_files()
	if files.has(filename) or files.has(filename_remap):
		return fullpath
	for nested_dir in dir.get_directories():
		var found := find_map_path(filename, root_dir.path_join(nested_dir))
		if found != "":
			return found
	return ""



func get_player_by_id(peer_id:int) -> BasePlayer:
	for player in get_tree().get_nodes_in_group("Player"):
		if player == null: continue
		if player.is_queued_for_deletion(): continue
		if player.get_multiplayer_authority() != peer_id: continue
		return player
	return null


@rpc("any_peer", "call_remote")
func kill(peer_id:int=multiplayer.get_unique_id()) -> void:
	var player := get_player_by_id(peer_id)
	if not player: return
	player.queue_free()


func get_inputs() -> Dictionary:
	var inputs := {}
	for action in InputMap.get_actions():
		if action.contains("_") or action.contains("Controller"): continue
		var keys := InputMap.action_get_events(action).filter(func (x:InputEvent) -> bool: return x is InputEventKey or x is InputEventMouseButton)
		if not keys.is_empty() and keys[0] is InputEventKey and keys[0].get_physical_keycode() == KEY_ESCAPE: continue
		inputs.get_or_add(action, keys)
	return inputs
