class_name Utils

static var ip_regex : RegEx = RegEx.new()


static func _static_init():
	ip_regex.compile(r"^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$")


static func validate_ip(ip:String) -> String:
	return ip if ip_regex.search(ip) else ""


static func get_subclasses(base: String) -> Array[String]:
	var subs : Array[String] = []
	for cls in ProjectSettings.get_global_class_list():
		if cls.get("base") != base: continue
		subs.append(cls.get("class"))
	return subs


static func get_class_from_string(name: String) -> Object:
	for info in ProjectSettings.get_global_class_list():
		if info["class"] != name: continue
		var scr : GDScript = load(info["path"]) as GDScript
		return scr
	return null
	
