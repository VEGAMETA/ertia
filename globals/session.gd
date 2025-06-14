extends Control

var console_scene = preload("uid://bu8kjkkq3vasm")

var console_node : Control = null

func _input(event) -> void:
	if event.is_action_pressed("debug_console"):
		if not console_node:
			if console_scene.can_instantiate():
				console_node = console_scene.instantiate()
				add_child(console_node)
			else: return printerr("Cannot instantiate console node")
		Console.shown = !Console.shown
		console_node.visible = Console.shown
	
