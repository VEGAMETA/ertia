class_name BaseGravity extends Node

static func set_gravity_vector(vector: Vector3) -> Vector3:
	ProjectSettings.set_setting("physics/3d/default_gravity_vector", vector)
	return vector

static func set_gravity_value(value: float) -> float:
	ProjectSettings.set_setting("physics/3d/default_gravity", value)
	return value

static func get_gravity_value() -> float:
	return ProjectSettings.get_setting("physics/3d/default_gravity")

static func get_gravity_vector() -> Vector3:
	return ProjectSettings.get_setting("physics/3d/default_gravity_vector")

static var rotation_vector = "rotation_vector"
static var body_rotation = "body_rotation"
static var text = "text"
static var color = "color"

static func get_by_vector(vector:Vector3) -> GravityDirection:
	match vector:
		Vector3.MODEL_TOP: return GravityDirections.TOP
		Vector3.MODEL_BOTTOM: return GravityDirections.BOTTOM
		Vector3.MODEL_LEFT: return GravityDirections.LEFT
		Vector3.MODEL_RIGHT: return GravityDirections.RIGHT
		Vector3.MODEL_FRONT: return GravityDirections.FRONT
		Vector3.MODEL_REAR: return GravityDirections.REAR
		_: return GravityDirections.ZERO

class GravityDirection:
	var rotation_vector : Vector3
	var body_rotation : Vector3
	var text : String
	var color : Color
	var flag : int

	func _init(_rotation_vector:Vector3, _body_rotation:Vector3, _text:String, _color:Color, _flag:int):
		rotation_vector = _rotation_vector
		body_rotation = _body_rotation
		text = _text
		color = _color

class GravityDirections: 
	static var TOP : GravityDirection = GravityDirection.new(
		Vector3.MODEL_TOP,
		Vector3(0, 0, PI),
		"TOP ↑",
		Color(0.0, 1.0, 0.0),
		0b000001,
	)
	static var BOTTOM : GravityDirection = GravityDirection.new(
		Vector3.MODEL_BOTTOM,
		Vector3.ZERO,
		"BOTTOM ↓",
		Color(1.0, 0.0, 1.0),
		0b000010
	)
	static var LEFT : GravityDirection = GravityDirection.new(
		Vector3.MODEL_LEFT,
		Vector3(0, 0, Math.PI_BY_2),
		"LEFT ←",
		Color(1.0, 0.0, 0.0),
		0b000100
	)
	static var RIGHT : GravityDirection = GravityDirection.new(
		Vector3.MODEL_RIGHT,
		Vector3(0, 0, Math.PI_BY_MINUS_2),
		"RIGHT →",
		Color(0.0, 1.0, 1.0),
		0b001000
	)
	static var FRONT : GravityDirection = GravityDirection.new(
		Vector3.MODEL_FRONT,
		Vector3(Math.PI_BY_MINUS_2, 0, 0),
		"FRONT ○",
		Color(0.0, 0.0, 1.0),
		0b010000
	)
	static var REAR : GravityDirection = GravityDirection.new(
		Vector3.MODEL_REAR,
		Vector3(Math.PI_BY_2, 0, 0),
		"REAR ◉",
		Color(1.0, 1.0, 0.0),
		0b100000
	)
	static var ZERO : GravityDirection = GravityDirection.new(
		Vector3.ZERO,
		Vector3.ZERO,
		"ZERO ∅",
		Color(1.0, 1.0, 1.0),
		0b000000
	)
