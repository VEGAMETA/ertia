extends Control

var offset_x : float
var offset_y : float
var offset_v2 : Vector2
const MULTIPLYER : float = 20.0
@onready var bubble : MeshInstance2D = %Bubble
@onready var player : Player = owner


func set_bubble_offset() -> void:
	offset_x = angle_difference(player.head.rotation.y, player.aim.rotation.y)
	offset_y = angle_difference(player.head.rotation.x, player.aim.rotation.x)
	offset_v2 = Vector2(offset_x * (1 + Math.TWO_BY_MINUS_PI * abs(player.head.rotation.x)), offset_y) * MULTIPLYER


func _process(delta:float) -> void:
	if not player: return
	set_bubble_offset()
	bubble.position = bubble.position.lerp(offset_v2, delta * 16)
