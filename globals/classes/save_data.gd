class_name SaveMetadata extends Resource

@export var time : float
@export var preview : Image
@export var type : Saver.SaveType
@export var  name : String

func setup(_time:float, _preview:Image, _type:Saver.SaveType, _name:String) -> void:
	time = _time
	preview = _preview
	type = _type
	name = _name
