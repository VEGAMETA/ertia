extends Control

@onready var label_value : Label = %Value

func _process(_delta:float) -> void:
	label_value.text = ""
	#fps
	label_value.text += "%d\n" % Engine.get_frames_per_second()
	#speed
	label_value.text += "%.2f\n" % owner.velocity.length()
