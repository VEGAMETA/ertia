class_name GravityObject extends RigidBody3D

@export var sfx : AudioStream = preload("res://assets/audio/sfx/punch_1.wav")

@export var gravity_vector := Gravity.gravity_vector
@export var new_velocity : float
@export var old_velocity : float = 0.0
@export var velocity_thereshold : float = 1.2
@export var playing :bool = false

@onready var player: Player
@onready var env_audio: AudioStreamPlayer3D

func _ready() -> void:
	env_audio = AudioStreamPlayer3D.new()
	env_audio.finished.connect(_on_audio_finished)
	Gravity.change_gravity.connect(_on_change_gravity)
	if not is_connected('body_entered', _on_body_entered):
		self.body_entered.connect(_on_body_entered)
	collision_layer = 4 # 3 layer
	collision_mask = 5 # 1, 3 mask layer
	max_contacts_reported = 1
	contact_monitor = true
	player = owner.find_child("Player")

func _on_change_gravity(new_gravity_vector: Vector3) -> void:
	apply_central_impulse(-new_gravity_vector)
	gravity_vector = new_gravity_vector

func _integrate_forces(state:PhysicsDirectBodyState3D) -> void:
	if player == null or state.get_contact_count() <= 0: return
	if player.get_slide_collision_count() == 0: return
	if player.grabber.grabbed_object != self: return
	for contact in range(state.get_contact_count()):
		if state.get_contact_collider_object(contact) != player: continue
		player.grabber.ungrab_object()
		apply_central_impulse(-(player.head.global_position - global_position) * mass * 2)
		return

func _on_body_entered(body:Node) -> void:
	if body == null: return
	new_velocity = (linear_velocity.length() + 1) * (angular_velocity.length() + 1)
	if body is BasePlayer:
		if player != null: player = body
	elif new_velocity > velocity_thereshold:
		if (playing and new_velocity > old_velocity) or not playing:
			env_audio.pitch_scale = 1.0 / new_velocity
			env_audio.play()
			playing = true
		old_velocity = new_velocity

func _on_audio_finished() -> void: playing = false
