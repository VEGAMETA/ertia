extends Node

var ip_regex : RegEx = RegEx.new()
var map_path : String = "res://3d/maps/"


func _ready():
	ip_regex.compile(r"^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$")


func validate_ip(ip:String) -> String:
	return ip if ip_regex.search(ip) else ""


func get_subclasses(base: String) -> Array[String]:
	var subs : Array[String] = []
	for cls in ProjectSettings.get_global_class_list():
		if cls.get("base") != base: continue
		subs.append(cls.get("class"))
	return subs


func get_class_from_string(_name: String) -> Object:
	for info in ProjectSettings.get_global_class_list():
		if info["class"] != _name: continue
		var scr : GDScript = load(info["path"]) as GDScript
		return scr
	return null


func get_maps() -> Array:
	var map_files : Array = Array(DirAccess.get_files_at(map_path))
	map_files = map_files.filter(func (path:String): return not path.ends_with(".tmp"))
	map_files = map_files.map(func (path:String): return path.get_file().get_basename())
	return map_files


func load_map(map:String) -> String:
	var full_map_path : String = get_full_map_name(map)
	_load_deferred.call_deferred(full_map_path)
	return full_map_path


func get_full_map_name(map:String) -> String:
	return map_path + map + ".tscn" if not map.ends_with(".tscn") else ""


func _load_deferred(map:String) -> void:
	if get_tree().change_scene_to_file(map): 
		Console.printerr("Cannot load the map", ERR_FILE_BAD_PATH)
