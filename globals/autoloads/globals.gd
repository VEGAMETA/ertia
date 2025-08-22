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


var server : Server
var client : Client
var command_handler : CommandHandler


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
	if event.is_action_pressed("Fullscreen"): toggle_fullscreen()
	if event.is_action_pressed("Menu"): Menu.toggle_menu()
	if event.is_action_pressed("debug_pause"): toggle_pause()
	if event.is_action_pressed("debug_console"): Console.toggle_console()
	if event.is_action_pressed("debug_mp"):
		server.serve()
		server.map = "sv_test"
		server.set_scene()
		await get_tree().process_frame
		await get_tree().process_frame
		server.spawn_player(1)
	if event.is_action_pressed("mp_spawn"):
		if multiplayer.is_server(): server.spawn_player(client.multiplayer.get_unique_id())
		else: client.request_spawn()
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
	# (not as smooth as I wish) So by default phys ticks = Screen Freq. but >= 60
	if Settings.phys_ticks == 0:
		if Engine.max_fps == 0: Engine.physics_ticks_per_second = roundi(DisplayServer.screen_get_refresh_rate())
		else: Engine.physics_ticks_per_second = Engine.max_fps
		get_tree().set_physics_interpolation_enabled(false)
	else:
		Engine.physics_ticks_per_second = Settings.phys_ticks
		if Engine.physics_ticks_per_second != Engine.max_fps:
			get_tree().set_physics_interpolation_enabled(true)


func quit() -> void:
	get_tree().quit()
