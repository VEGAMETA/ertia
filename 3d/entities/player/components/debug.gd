class_name PlayerDebug extends Node

@onready var player : BasePlayer = owner

var debug_view_list : Array[int] = [1, 3, 4, 5, 26, 0]

func _on_debug(function:Callable, args:Array=[]) -> Variant:
	return function.callv(args) if Settings.debug else null

func _input(event:InputEvent) -> void:
	if event.is_action_pressed("debug_firstperson"):
		_on_debug(_handle_firstperson)
	if event.is_action_pressed("debug_view"):
		_on_debug(_handle_debug_view)

func _handle_debug_view() -> void:
	debug_view_list.append(debug_view_list[0])
	get_viewport().debug_draw = debug_view_list.pop_front()

func _handle_firstperson() -> void:
	if not Settings.debug: return
	player.firstperson = !player.firstperson
	if not player is Player: return
	player.remote_camera.position = Vector3(0.0, 0.0, 4.0 * int(!player.firstperson))
