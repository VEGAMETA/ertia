class_name Abstract
extends Object

static func have(obj: Object, cls: Abstract) -> bool:
	var meta: Abstract = obj._get("meta")
	return is_instance_of(meta, cls) if meta else false
