extends Control

@onready var label_value : Label = %Value

func _process(_delta):
	label_value.text = str(Engine.get_frames_per_second())
