class_name PlayerUI extends Node


func _ready() -> void:
	if not is_multiplayer_authority():
		queue_free()
