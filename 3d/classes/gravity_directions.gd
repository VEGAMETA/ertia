@tool
class_name GravityDirections

static var TOP := GravityDirection.new(
	Vector3.MODEL_TOP,
	Vector3(0, 0, PI),
	"TOP ↑",
	Color(0.0, 1.0, 0.0),
	0b000001,
)
static var BOTTOM := GravityDirection.new(
	Vector3.MODEL_BOTTOM,
	Vector3.ZERO,
	"BOTTOM ↓",
	Color(1.0, 0.0, 1.0),
	0b000010
)
static var LEFT := GravityDirection.new(
	Vector3.MODEL_LEFT,
	Vector3(0, 0, Math.PI_BY_2),
	"LEFT ←",
	Color(1.0, 0.0, 0.0),
	0b000100
)
static var RIGHT := GravityDirection.new(
	Vector3.MODEL_RIGHT,
	Vector3(0, 0, Math.PI_BY_MINUS_2),
	"RIGHT →",
	Color(0.0, 1.0, 1.0),
	0b001000
)
static var FRONT := GravityDirection.new(
	Vector3.MODEL_FRONT,
	Vector3(Math.PI_BY_MINUS_2, 0, 0),
	"FRONT ○",
	Color(0.0, 0.0, 1.0),
	0b010000
)
static var REAR := GravityDirection.new(
	Vector3.MODEL_REAR,
	Vector3(Math.PI_BY_2, 0, 0),
	"REAR ◉",
	Color(1.0, 1.0, 0.0),
	0b100000
)
static var ZERO := GravityDirection.new(
	Vector3.ZERO,
	Vector3.ZERO,
	"ZERO ∅",
	Color(1.0, 1.0, 1.0),
	0b000000
)

static var directions : Array[GravityDirection] = [TOP, BOTTOM, LEFT, RIGHT, FRONT, REAR, ZERO]

static var by_flag : Dictionary = directions.reduce(
	func(accum:Dictionary, direction:GravityDirection) -> Dictionary:
		accum.set(direction.flag, direction)
		return accum
, {}
)
static var by_vector: Dictionary = directions.reduce(
	func(accum:Dictionary, direction:GravityDirection) -> Dictionary:
		accum.set(direction.rotation_vector, direction)
		return accum
, {}
)

#func _init():
	#for direction in directions:
		#by_flag[direction.flag] = direction
		#by_vector[direction.rotation_vector] = direction
