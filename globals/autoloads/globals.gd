extends Node

@export var mouse_sens : float = 1.0
@export var last_load_point : int = 0

enum Collisions {
	ALL = ~0,
	NONE = 0,
	STATIC = int(pow(2, 0)),
	PLAYER = int(pow(2, 1)),
	DYNAMIC = int(pow(2, 2)),
	BATTERY = int(pow(2, 3)),
	GRAVITY_AREAS = int(pow(2, 4)),
	USABLE = int(pow(2, 5)),
}

func inv_collision(collision:Collisions) -> int:
	return Collisions.ALL ^ collision


func _ready():
	reset_physics()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _notification(what):
	match what:
		NOTIFICATION_APPLICATION_FOCUS_IN:
			get_tree().paused = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			reset_physics()
		NOTIFICATION_PAUSED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		NOTIFICATION_UNPAUSED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func reset_physics():
	var refresh_rate := int(DisplayServer.screen_get_refresh_rate())
	# We do have physics interpolation but it is still too clunky (not smooth)
	Engine.physics_ticks_per_second = refresh_rate 
	#Engine.max_fps = refresh_rate

func _on_despawn_area_body_exited(body):
	body.queue_free()
