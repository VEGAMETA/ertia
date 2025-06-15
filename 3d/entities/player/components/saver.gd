class_name SaveComponent extends Node

@onready var player : Player = owner


func _ready() -> void:
	Saver.save_init.connect(_on_save_init)
	Saver.save_finish.connect(_on_save_finish)


func _input(event) -> void:
	if event.is_action_pressed("Quicksave"): Saver.quicksave()
	if event.is_action_pressed("Quickload"): Saver.quickload()


func _on_save_init() -> void: 
	player.save()


func _on_save_finish() -> void: pass
