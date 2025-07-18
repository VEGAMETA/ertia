@tool
extends Sprite3D

@onready var rotator : Viewport = %Rotator

func _ready() -> void:
	get_texture().set_viewport_path_in_scene(rotator.get_path())
