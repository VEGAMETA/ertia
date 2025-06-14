extends Node
## Main Global class

enum Collisions {
	ALL = ~0,
	NONE = 0,
	STATIC = 2 ** 0,
	PLAYER = 2 ** 1,
	DYNAMIC = 2 ** 2,
	BATTERY = 2 ** 3,
	GRAVITY_AREAS = 2 ** 4,
	USABLE = 2 ** 5,
}

static var debug : bool = OS.is_debug_build()

static var server = Server.new()
static var client = Client.new()

@export var mouse_sens : float = 1.0
@export var just_unpaused : bool = false


func _ready():
	add_child(server)
	add_child(client)
	process_mode = Node.PROCESS_MODE_ALWAYS
	reset_physics()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# TO SERVER
func _input(event):
	if event.is_action_pressed("Fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else: 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if Input.is_action_pressed("Pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
	if event is InputEventMouseButton and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().paused = false


func _notification(what):
	match what:
		NOTIFICATION_APPLICATION_FOCUS_IN:
			get_tree().paused = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			reset_physics()
		NOTIFICATION_PAUSED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		NOTIFICATION_UNPAUSED:
			just_unpaused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			await get_tree().physics_frame
			just_unpaused = false
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		NOTIFICATION_WM_SIZE_CHANGED: pass


func _on_despawn_area_body_exited(body):
	body.queue_free()


func inv_collision(collision:Collisions) -> int:
	return Collisions.ALL ^ collision


func reset_physics():
	# NOTE: We do have physics interpolation but it is still too clunky (not smooth)
	var refresh_rate := int(DisplayServer.screen_get_refresh_rate()) 
	Engine.physics_ticks_per_second = refresh_rate 
	# Engine.max_fps = refresh_rate


func quit():
	get_tree().quit()
