class_name SaveMetadata extends Resource

var time : float
var preview : Image
var type : Saver.SaveType
var name : String

func _init(_time:float, _preview:Image, _type:Saver.SaveType, _name:String):
	time = _time
	preview = _preview
	type = _type
	name = _name
