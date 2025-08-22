extends Node3D

const initial_rotation_multiplyer : float = 0.1
var rotation_multiplyer : float = initial_rotation_multiplyer
var new_rot : float = 0.0

func _ready() -> void:
	if not owner: return
	if not owner.owner: return
	if owner.owner is not BasePlayer: return
	set_syncronized.call_deferred()

func set_syncronized() -> void:
	if owner.owner.multiplayer_syncronizer.replication_config.has_property(^"Components/GravityDevice/Model:rotation"): return
	owner.owner.multiplayer_syncronizer.replication_config.add_property(^"Components/GravityDevice/Model:rotation")#NodePath("%s:rotation"%get_path()))

func _process(delta:float) -> void:
	rotation_multiplyer = lerpf(rotation_multiplyer, initial_rotation_multiplyer, delta * rotation_multiplyer)
	new_rot = lerpf(rotation.y, rotation.y + PI, delta * rotation_multiplyer)
	if is_nan(new_rot) or is_inf(new_rot): return
	rotation.y = new_rot

func rotate_gravitate(value:float) -> void:
	rotation_multiplyer = value

func _input(event:InputEvent) -> void:
	if not owner.is_multiplayer_authority(): return
	if event.is_action_pressed("Attack"):
		if Settings.vibration: Input.start_joy_vibration(0, 0.6, 0.0, 0.17)
		rotate_gravitate(10)
