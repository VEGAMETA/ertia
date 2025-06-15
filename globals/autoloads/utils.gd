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


func get_maps() -> PackedStringArray:
	return DirAccess.get_files_at(map_path)


func load_map(map:String) -> void:
	map += ".tscn" if not map.ends_with(".tscn") else ""
	_load_deferred.call_deferred(map_path + map)


func _load_deferred(map:String) -> void:
	if get_tree().change_scene_to_file(map): 
		printerr("Cannot load the map", ERR_FILE_BAD_PATH)
