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


@export var mouse_sens : float = 1.0
@export var just_unpaused : bool = false


func _ready() -> void:
	command_handler = CommandHandler.new()
	server = Server.new()
	client = Client.new()
	add_child(command_handler)
	add_child(server)
	add_child(client)
	process_mode = Node.PROCESS_MODE_ALWAYS
	reset_physics()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# TO SERVER
func _input(event:InputEvent) -> void:
	if event.is_action_pressed("Fullscreen"):
		toggle_fullscreen()
	if event.is_action_pressed("Pause"):
		toggle_pause()
	#if event is InputEventMouseButton:
		#if get_tree().paused: get_tree().set_pause(false)
		#notify_deferred_thread_group(
			#NOTIFICATION_PAUSED if get_tree().is_paused() else \
			#NOTIFICATION_UNPAUSED
		#)


func toggle_pause() -> void:
	if !get_tree().current_scene.is_multiplayer_authority(): return Console.printerr("Cannot pause")
	_toggle_pause.rpc()
	_toggle_mouse.rpc()

@rpc("any_peer", "call_local", "reliable")
func _toggle_pause() -> void:
	get_tree().set_pause(!get_tree().is_paused())
	notify_deferred_thread_group(
		NOTIFICATION_PAUSED if get_tree().is_paused() else \
		NOTIFICATION_UNPAUSED
	)

func toggle_mouse(hide:bool=true) -> void:
	Input.set_mouse_mode(
		Input.MOUSE_MODE_CAPTURED if hide else \
		Input.MOUSE_MODE_VISIBLE
	)

@rpc("any_peer", "call_remote", "unreliable")
func _toggle_mouse() -> void:
	Input.set_mouse_mode(
		Input.MOUSE_MODE_CAPTURED if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE else \
		Input.MOUSE_MODE_VISIBLE
	)

	


func toggle_fullscreen() -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_WINDOWED if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else \
		DisplayServer.WINDOW_MODE_FULLSCREEN
	)


func _notification(what:int) -> void:
	match what:
		NOTIFICATION_PAUSED: pass
			#toggle_mouse(false)
		NOTIFICATION_UNPAUSED:
			#toggle_mouse(true)
			just_unpaused = true
			await get_tree().physics_frame
			just_unpaused = false
		NOTIFICATION_APPLICATION_FOCUS_IN:
			#toggle_mouse(true)
			reset_physics()
		NOTIFICATION_APPLICATION_FOCUS_OUT: pass
			#toggle_mouse(false)
		#NOTIFICATION_SCENE_INSTANTIATED:
			#get_tree().set_pause(false)
		NOTIFICATION_WM_SIZE_CHANGED: pass


func _on_despawn_area_body_exited(body:Node) -> void:
	body.queue_free()


func inv_collision(collision:Collisions) -> int:
	return Collisions.ALL ^ collision


func reset_physics() -> void:
	# NOTE: We do have physics interpolation but it is still too clunky 
	# (not as smooth as I wish)
	var refresh_rate := int(DisplayServer.screen_get_refresh_rate()) 
	Engine.physics_ticks_per_second = refresh_rate 
	# Engine.max_fps = refresh_rate


func quit() -> void:
	get_tree().quit()
