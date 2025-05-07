class_name FlashlightComponent extends SpotLight3D

@export var active : bool = false

func _ready():
	visible = active

func _input(event) -> void:
	if event.is_action_pressed("Flashlight"): 
		active = !active
		visible = !visible

func _process(delta) -> void:
	light_energy += sin(Time.get_ticks_msec()) * delta
