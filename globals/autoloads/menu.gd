extends Node

signal menu_toggle(_visible:bool)

const MENU_UID : String = "uid://camwqks3jp737"

var menu_scene : PackedScene 
var menu_node : MainMenu = null
var toggled := false

func _init() -> void:
	menu_scene = load(MENU_UID)
	menu_toggle.connect(_on_toggle)


func _input(event:InputEvent) -> void:
	if event.is_action_pressed("Menu"): toggle_menu()


func _on_toggle(_visible:bool) -> void:
	if _visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _toggle_menu() -> Error:
	if menu_node:
		toggled = menu_node.toggle()
		if menu_node.is_inside_tree(): return OK
	if menu_scene.can_instantiate():
		if get_tree().current_scene == null: return Console.printerr("Cannot instantiate menu node current_scene is null", ERR_CANT_CREATE)
		menu_node = menu_scene.instantiate()
		toggled = true
		get_tree().current_scene.add_child(menu_node)
	else: return Console.printerr("Cannot instantiate menu node", ERR_CANT_CREATE)
	return OK


func toggle_menu() -> void:
	if get_tree().current_scene is MainMenu: return
	if get_tree().current_scene is Session: return
	if not _toggle_menu(): menu_toggle.emit(toggled)


func menu() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Utils._load_deferred(MENU_UID)
