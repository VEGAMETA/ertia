class_name PlayerAudioComponent extends Node3D

@onready var step : AudioStreamPlayer3D = $Step
@onready var player: BasePlayer = owner

const MIN_VEL : float = 3.0
const MAX_VEL : float = 16.0
const DEVIATION : float = 0.05
const FALL_PITCH : float = 0.5
const PITCH_MULTIPLYER : float = 0.2

func _physics_process(_delta) -> void:
	play_footsteps()

func play_footsteps() -> void:
	if player.velocity_length > MAX_VEL or player.velocity_length < MIN_VEL: return
	if player.is_on_wall() or not player.is_on_floor(): return
	if (player.prev_velocity * player.positive_gravity_vector).length() > MIN_VEL:
		step.pitch_scale = randfn(FALL_PITCH, DEVIATION)
		return step.play()
	if not player.input_dir.length(): return
	if step.is_playing(): return
	step.pitch_scale = randfn(player.velocity_length * PITCH_MULTIPLYER, DEVIATION)
	step.play()
