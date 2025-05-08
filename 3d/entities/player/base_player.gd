class_name BasePlayer
extends CharacterBody3D

var meta = APlayer.new()

var mouse_sensibility : float = Globals.mouse_sens * 17 / 15000
var velocity_length : float = 0.0

#Movement
const MAX_VELOCITY_RUN : float = 7.0
const MAX_VELOCITY_GROUND : float = 4.25
const MAX_VELOCITY_WALK : float = 2.0 
const MAX_VELOCITY_AIR : float = 1.75
const STOP_SPEED : float = 1.5
const FRICTION : float = 8.0
const FALL_CONSTANT : float = 1.25
const WALL_GRIP : float = 0.15
const LEAN_SCALE : float = 0.03
const DEVIATION : float = 0.001

@export var prev_velocity: Vector3
@export var input_dir: Vector2
@export var direction: Vector3
@export var current_speed: float
@export var drop: float
@export var walking : bool = false
@export var running : bool = false

#Gravity
@export var gravity : float
@export var gravity_mask : Vector3 = Vector3.ZERO
@export var gravity_vector : Vector3 = Vector3.ZERO
@export var inv_gravity_vector : Vector3 = Vector3.ZERO
@export var positive_gravity_vector : Vector3 = Vector3.ZERO
@export var current_ps3d_gravity_vector : Vector3 = Vector3.ZERO

@export var firstperson : bool = true

@onready var head : Node3D = %Head
@onready var holder : Node3D =  %Holder
@onready var gravity_area_watcher : ShapeCast3D = %GravityAreaWatcher

func _notification(what) -> void:
	match what:
		NOTIFICATION_PAUSED:
			walking = false
			running = false

func _ready() -> void:
	_initialize()

func _initialize():
	if current_ps3d_gravity_vector == Vector3.ZERO: 
		current_ps3d_gravity_vector = Gravity.gravity_vector
	gravity = Gravity.gravity
	set_gravity(Gravity.gravity_vector)
	await get_tree().physics_frame
	gravity_area_watcher.force_shapecast_update()

func _input(event:InputEvent) -> void:
	input_dir = Input.get_vector("StrafeLeft", "StrafeRight", "Forward", "Backward")
	if event.is_action_released("Walk"): walking = false
	if event.is_action_pressed("Walk"): walking = true
	running = Input.is_action_pressed("Run")

func _physics_process(delta:float) -> void:
	_set_movement_direction()
	if is_on_floor(): _update_velocity_ground(delta)
	else: _update_velocity_air(delta)
	prev_velocity = velocity
	move_and_slide()
	_lean_head(delta)
	_wall_handling()
	_move_holder(delta)
	velocity_length = velocity.length()

func accelerate(max_speed: float) -> void:
	velocity += direction * clamp(max_speed - velocity.dot(direction) , 0, 1) * input_dir.length()

func _update_velocity_ground(delta) -> void:
	current_speed = (velocity * gravity_mask).length()
	if current_speed != 0:
		drop = max(STOP_SPEED, current_speed) * FRICTION * delta
		velocity *= max(current_speed - drop, 0) / current_speed
	if walking: return accelerate(MAX_VELOCITY_WALK)
	if running: return accelerate(MAX_VELOCITY_RUN)
	return accelerate(MAX_VELOCITY_GROUND)

func _update_velocity_air(delta) -> void:
	velocity += gravity_vector * gravity * delta * FALL_CONSTANT
	accelerate(MAX_VELOCITY_AIR)

func _lean_head(delta) -> void:
	head.rotation.z = lerp(head.rotation.z, 0.0 if velocity == Vector3.ZERO else -input_dir.x * LEAN_SCALE, delta * 10.0)

func _wall_handling() -> void:
	if is_on_wall(): velocity -= velocity * gravity_mask * WALL_GRIP

func _move_holder(delta) -> void:
	holder.global_position = lerp(holder.global_position, head.global_position, delta * 16)
	holder.rotation.x = lerp_angle(holder.rotation.x, head.rotation.x , delta * 16)
	holder.rotation.y = lerp_angle(holder.rotation.y, head.rotation.y , delta * 16)

func _set_movement_direction() -> void:
	direction = Basis(inv_gravity_vector, head.rotation.y) * Vector3(
		input_dir.x * (-1 if gravity_vector.y == 1 else 1) if gravity_vector.x == 0 else 0.0,
		input_dir.x * gravity_vector.x + input_dir.y * gravity_vector.z,
		input_dir.y if gravity_vector.z == 0 else 0.0
	)
	direction *= gravity_mask
	direction = direction.normalized() 

func set_gravity(new_gravity_vector:Vector3) -> void:
	gravity_vector = new_gravity_vector
	inv_gravity_vector = -gravity_vector
	positive_gravity_vector = new_gravity_vector * new_gravity_vector
	gravity_mask = Vector3.ONE - positive_gravity_vector
	up_direction = -new_gravity_vector
	set_gravity_global(new_gravity_vector)	
	if gravity_area_watcher.is_colliding(): return

func set_gravity_global(new_gravity_vector:Vector3) -> void:
	current_ps3d_gravity_vector = new_gravity_vector
	Gravity.change_gravity_vector(new_gravity_vector)
