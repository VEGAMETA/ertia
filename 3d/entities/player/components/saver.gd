class_name SaveComponent extends Node

@onready var player : Player = owner

func _ready() -> void:
	Saver.save_init.connect(_on_save_init)
	Saver.save_finish.connect(_on_save_finish)

func _input(event) -> void:
	if event.is_action_pressed("Quicksave"): quicksave()
	if event.is_action_pressed("Quickload"): quickload()

func quicksave() -> void:
	player.save()
	Saver.save(Saver.fetch_metadata(Saver.SaveType.QUICKSAVE))

func quickload() -> void:
	Saver.load_last_save(Saver.SaveType.QUICKSAVE)

func _on_save_init() -> void: pass
func _on_save_finish() -> void: pass
