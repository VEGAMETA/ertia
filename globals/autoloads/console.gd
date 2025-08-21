extends Node

signal stream_update
signal console_toggle(_visible:bool)

const CONSOLE_UID : String = "uid://bu8kjkkq3vasm"
var console_scene : PackedScene
var console_node : ConsoleWindow = null
var command_history : Array[String] = []

var stream : String: 
	set(v): 
		stream = v
		stream_update.emit()


func _ready() -> void:
	console_scene = load(CONSOLE_UID)
	process_mode = Node.PROCESS_MODE_ALWAYS


func toggle_console() -> void:
	if not Settings.debug:
		if console_node != null and console_node.visible:
			_toggle_console()
			console_toggle.emit(console_node.visible)
		return
	if not _toggle_console(): 
		console_toggle.emit(console_node.visible)


func _toggle_console() -> Error:
	if console_node:
		console_node.set_visible(not console_node.is_visible())
		if console_node.is_inside_tree(): return OK
	if console_scene.can_instantiate():
		console_node = console_scene.instantiate()
		get_tree().current_scene.add_child(console_node)
	else: return Console.printerr("Cannot instantiate console node", ERR_CANT_CREATE)
	return OK


func clear() -> void:
	stream = ""


func print(text:String) -> void:
	print(text)
	stream += "%s\n" % text


func printerr(text:String, error:Error=OK) -> Error:
	printerr(error, " (%s) ---> " % error_string(error) + text)
	stream += "[color=red]%s[/color]\n" % text
	return error

func printwarn(text:String, warning:String) -> void:
	print(text, "\nWARNING (%s) ---> " % warning)
	stream += "[color=yellow]%s[/color]\n" % text
