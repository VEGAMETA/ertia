extends Node3D

const initial_rotation_multiplyer : float = 0.1
var rotation_multiplyer : float = initial_rotation_multiplyer
var new_rot : float = 0.0

func _process(delta) -> void:
	rotation_multiplyer = lerpf(rotation_multiplyer, initial_rotation_multiplyer, delta * rotation_multiplyer)
	new_rot = lerpf(rotation.y, rotation.y + PI, delta * rotation_multiplyer)
	if is_nan(new_rot) or is_inf(new_rot): return
	rotation.y = new_rot

func rotate_gravitate(value:float) -> void:
	rotation_multiplyer = value

func _input(event:InputEvent) -> void:
	input.rpc(event)

@rpc("authority", "call_local", "reliable")
func input(event:InputEvent) -> void:
	if event.is_action_pressed("Attack"):
		Input.start_joy_vibration(0, 0.6, 0.0, 0.17)
		rotate_gravitate(10)
