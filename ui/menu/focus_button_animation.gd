extends Node


func _ready() -> void:
	get_children().map(func (x: AnimationPlayer) -> void: x.seek(randf_range(0.5, 2.1)))
	Menu.menu_toggle.connect(toggle_animations)


func toggle_animations(status:bool) -> void:
	get_children().map(func (x: AnimationPlayer) -> void: x.play() if status else x.pause())
