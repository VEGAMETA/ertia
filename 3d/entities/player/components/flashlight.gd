class_name FlashlightComponent extends SpotLight3D

func _input(event:InputEvent) -> void:
	if event.is_action_pressed("Flashlight"):
		visible = !visible

func _process(delta:float) -> void:
	light_energy += sin(Time.get_ticks_msec()) * delta
