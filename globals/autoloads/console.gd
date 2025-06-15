extends Node

signal stream_updated

var console_scene : PackedScene = preload("uid://bu8kjkkq3vasm")
var console_node : ConsoleWindow = null
var command_history : Array[String] = []

var stream : String : 
	set(v): 
		stream = v
		stream_updated.emit()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event) -> void:
	if event.is_action_pressed("debug_console"):
		if console_node: console_node.visible = !console_node.visible 
		if not console_node:
			if console_scene.can_instantiate():
				console_node = console_scene.instantiate()
				get_tree().current_scene.add_child(console_node)
			else: return printerr("Cannot instantiate console node")
	#if event.is_action("ui_cancel"):
		#if shown: 
			#shown = false
			#console_node.visible = shown


func clear() -> void:
	stream = ""


func print(text:String) -> void:
	stream += text


func printerr(text:String, error:Error=OK) -> Error:
	stream += "[color=red]%s[/color]\n" % text
	return error
