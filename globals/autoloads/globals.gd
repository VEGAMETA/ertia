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

var debug : bool = OS.is_debug_build()

var server : Server
var client : Client
var command_handler : CommandHandler

var previous_mouse_mode : Input.MouseMode

@export var mouse_sens : float = 1.0
@export var just_unpaused : bool = false


func _ready():
	command_handler = CommandHandler.new()
	server = Server.new()
	client = Client.new()
	add_child(command_handler)
	add_child(server)
	add_child(client)
	process_mode = Node.PROCESS_MODE_ALWAYS
	reset_physics()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	previous_mouse_mode = Input.get_mouse_mode()

# TO SERVER
func _input(event):
	if event.is_action_pressed("Fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else: 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if event.is_action_pressed("Pause"):
		get_tree().set_pause(!get_tree().is_paused())
		notify_deferred_thread_group(
			NOTIFICATION_PAUSED if get_tree().is_paused() else \
			NOTIFICATION_UNPAUSED
		)
	if event is InputEventMouseButton:
		if get_tree().paused: get_tree().set_pause(false)
		notify_deferred_thread_group(
			NOTIFICATION_PAUSED if get_tree().is_paused() else \
			NOTIFICATION_UNPAUSED
		)



func _notification(what):
	match what:
		NOTIFICATION_PAUSED:
			if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
				previous_mouse_mode = Input.get_mouse_mode()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		NOTIFICATION_UNPAUSED:
			just_unpaused = true
			if previous_mouse_mode != Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(previous_mouse_mode)
			await get_tree().physics_frame
			just_unpaused = false
		NOTIFICATION_APPLICATION_FOCUS_IN:
			get_tree().set_pause(false)
			Input.set_mouse_mode(previous_mouse_mode)
			reset_physics()
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
				previous_mouse_mode = Input.get_mouse_mode()
			get_tree().set_pause(true)
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		NOTIFICATION_SCENE_INSTANTIATED:
			get_tree().set_pause(false)
		NOTIFICATION_WM_SIZE_CHANGED: pass


func _on_despawn_area_body_exited(body):
	body.queue_free()


func inv_collision(collision:Collisions) -> int:
	return Collisions.ALL ^ collision


func reset_physics():
	# NOTE: We do have physics interpolation but it is still too clunky 
	# (not as smooth as I wish)
	var refresh_rate := int(DisplayServer.screen_get_refresh_rate()) 
	Engine.physics_ticks_per_second = refresh_rate 
	# Engine.max_fps = refresh_rate


func quit():
	get_tree().quit()
