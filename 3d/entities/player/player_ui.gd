class_name PlayerUI extends Node


func _ready():
	if not is_multiplayer_authority():
		queue_free()
