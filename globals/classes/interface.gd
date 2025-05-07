class_name Interface
extends Object

var interface = null

static func have(obj:Object, interface:Interface) -> bool:
	var imeta: Abstract = obj._get("imeta")
	return is_instance_of(imeta, interface) if imeta else false
