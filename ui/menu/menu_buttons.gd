extends VBoxContainer

const MAX_SKEW_X : float = 0.5
const MAX_SKEW_Y : float = 0.2
const MAX_SKEW_X_TH : float = MAX_SKEW_X * 0.7
const MAX_SKEW_Y_TH : float = MAX_SKEW_Y * 0.7
const MAX_CORNER : float = 50
const MAX_CORNER_TH : int = 35
const MIN_CORNER_TH : int = 5
const MAX_V : float = 0.4
const MIN_V : float = 0.2

var col := Color("417486")#Color("18323b")
var v_new : float = 0.2
var skew := Vector2(MAX_SKEW_X, MAX_SKEW_Y)
var skew_new := Vector2(-MAX_SKEW_X, -MAX_SKEW_Y)
var corners : Array[float] = [
	randf_range(0, MAX_CORNER),
	randf_range(0, MAX_CORNER),
	randf_range(0, MAX_CORNER),
	randf_range(0, MAX_CORNER)
]
var corners_new : Array[float] = [MAX_CORNER, 0.0, MAX_CORNER, 0.0]

func _ready() -> void:
	theme.get_stylebox(&"focus", &"Button").skew = skew
	

func _process(delta: float) -> void:
	skew.x = lerp(skew.x, skew_new.x, delta*0.53)
	skew.y = lerp(skew.y, skew_new.y, delta*0.25)
	if skew.x >= MAX_SKEW_X_TH: skew_new.x = -MAX_SKEW_X
	elif skew.x <= -MAX_SKEW_X_TH: skew_new.x = MAX_SKEW_X
	if skew.y >= MAX_SKEW_Y_TH: skew_new.y = -MAX_SKEW_Y
	elif skew.y <= -MAX_SKEW_Y_TH: skew_new.y = MAX_SKEW_Y
	theme.get_stylebox(&"focus", &"Button").skew = skew
	for i in range(4):
		if corners[i] >= MAX_CORNER_TH: corners_new[i] = 0.0
		elif corners[i] <= MIN_CORNER_TH: corners_new[i] = MAX_CORNER
		corners[i] = lerp(corners[i], corners_new[i], delta * 0.25)
	theme.get_stylebox(&"focus", &"Button").corner_radius_top_left = corners[0]
	theme.get_stylebox(&"focus", &"Button").corner_radius_top_right = corners[1]
	theme.get_stylebox(&"focus", &"Button").corner_radius_bottom_left = corners[2]
	theme.get_stylebox(&"focus", &"Button").corner_radius_bottom_right = corners[3]
	if col.v >= MAX_V: v_new = MIN_V - 0.1
	elif col.v <= MIN_V: v_new = MAX_V + 0.1
	col.v = lerp(col.v, v_new, delta * 0.125)
	theme.get_stylebox(&"focus", &"Button").bg_color = col
