class_name JumpComponent extends Node

const JUMP_VELOCITY : float = 5.25

@export var wish_jump : bool = false
@export var can_jump : bool = false

@onready var player : BasePlayer = owner

signal jump

func _input(event):
	#if not owner.is_multiplayer_authority(): return
	if event.is_action_pressed("Jump"): wish_jump = true
	if event.is_action_released("Jump"): wish_jump = false

func _physics_process(_delta:float) -> void:
	if wish_jump and can_jump: _jump()
	can_jump = player.is_on_floor()

func _jump() -> void:
	player.accelerate(player.MAX_VELOCITY_AIR)
	player.velocity -= player.gravity_vector * JUMP_VELOCITY
	_handle_collisions()
	wish_jump = false
	jump.emit()

func _handle_collisions() -> void:
	if player.collision_stand.disabled: return
	player.collision_crouch.position.y = 0.0
