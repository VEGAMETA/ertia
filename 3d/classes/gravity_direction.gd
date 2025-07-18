class_name GravityDirection

var rotation_vector : Vector3
var body_rotation : Vector3
var text : String
var color : Color
var flag : int


func _init(
	_rotation_vector:Vector3, 
	_body_rotation:Vector3, 
	_text:String, 
	_color:Color, 
	_flag:int) -> void:
	rotation_vector = _rotation_vector
	body_rotation = _body_rotation
	text = _text
	color = _color
	flag = _flag
