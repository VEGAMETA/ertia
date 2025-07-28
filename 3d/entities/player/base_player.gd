class_name BasePlayer
extends CharacterBody3D

var mouse_sensibility : float = Globals.mouse_sens * 17 / 15000
var velocity_length : float = 0.0

#Movement
const MAX_VELOCITY : float = 9.0
const MAX_VELOCITY_RUN : float = 6.75
const MAX_VELOCITY_GROUND : float = 4.25
const MAX_VELOCITY_WALK : float = 2.0 
const MAX_VELOCITY_AIR : float = 1.75
const STOP_SPEED : float = 1.5
const FRICTION : float = 8.0
const FALL_CONSTANT : float = 1.25
const WALL_GRIP : float = 0.15
const LEAN_SCALE : float = 0.03
const DEVIATION : float = 0.001

@export var initial_position : Vector3
@export var uuid : String = UUID.v4()
@export var prev_velocity: Vector3
@export var input_dir: Vector2
@export var direction: Vector3
@export var direct_velocity: float
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

@onready var holder : Node3D =  %Holder
@onready var head : Node3D = %Head
@onready var vision : Node3D = %Vision
@onready var gravity_area_watcher : ShapeCast3D = %GravityAreaWatcher
@onready var multiplayer_syncronizer : MultiplayerSynchronizer = %MultiplayerSynchronizer


func _notification(what:int) -> void:
	match what:
		NOTIFICATION_PAUSED:
			walking = false
			running = false
		NOTIFICATION_UNPAUSED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		NOTIFICATION_APPLICATION_FOCUS_IN:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _enter_tree() -> void:
	if Globals.client.connected():
		set_multiplayer_authority(str(name).to_int())


func _init() -> void:
	add_to_group("Player")


func _ready() -> void:
	if not is_multiplayer_authority(): return
	Menu.menu_toggle.connect(clear_inputs)
	Console.console_toggle.connect(clear_inputs)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	initial_position = global_position
	initial_position.y += 1.5
	if current_ps3d_gravity_vector == Vector3.ZERO: 
		current_ps3d_gravity_vector = Gravity.gravity_vector
	Console.print("v %d" % current_ps3d_gravity_vector.y)
	gravity = Gravity.gravity
	set_gravity(current_ps3d_gravity_vector)
	set_gravity_global(current_ps3d_gravity_vector)
	await Engine.get_main_loop().physics_frame
	gravity_area_watcher.force_shapecast_update()


func _input(event:InputEvent) -> void:
	if not is_multiplayer_authority(): return
	input_dir = Input.get_vector("StrafeLeft", "StrafeRight", "Forward", "Backward")
	if event.is_action_released("Walk"): walking = false
	if event.is_action_pressed("Walk"): walking = true
	running = Input.is_action_pressed("Run")


func _physics_process(delta:float) -> void:
	get_tree()
	_set_movement_direction()
	if is_on_floor(): _update_velocity_ground(delta)
	else: _update_velocity_air(delta)
	_limit_speed()
	prev_velocity = velocity
	move_and_slide()
	_lean_head(delta)
	_wall_handling()
	_move_holder(delta)
	velocity_length = velocity.length()


func clear_inputs(disabled:bool=true) -> void:
	set_input_recursively(self, not disabled)
	Input.set_mouse_mode(
		Input.MOUSE_MODE_CAPTURED if not disabled else\
		Input.MOUSE_MODE_VISIBLE
	)
	input_dir *= int(not disabled)


func set_input_recursively(node: Node, enabled: bool) -> void:
	node.set_process_input(enabled)
	node.set_process_unhandled_input(enabled)
	for child in node.get_children():
		if child is Node: set_input_recursively(child, enabled)


func accelerate(max_speed: float) -> void:
	velocity += direction * clamp(max_speed - velocity.dot(direction) , 0, 1) * input_dir.length()


func _update_velocity_ground(delta:float) -> void:
	current_speed = (velocity * gravity_mask).length()
	if current_speed != 0:
		drop = max(STOP_SPEED, current_speed) * FRICTION * delta
		velocity *= max(current_speed - drop, 0) / current_speed
	if walking: return accelerate(MAX_VELOCITY_WALK)
	if running: return accelerate(MAX_VELOCITY_RUN)
	return accelerate(MAX_VELOCITY_GROUND)


func _update_velocity_air(delta:float) -> void:
	velocity += gravity_vector * gravity * delta * FALL_CONSTANT
	accelerate(MAX_VELOCITY_AIR)


func _lean_head(delta:float) -> void:
	head.rotation.z = lerp(head.rotation.z, 0.0 if velocity == Vector3.ZERO else -input_dir.x * LEAN_SCALE, delta * 10.0)


func _limit_speed() -> void:
	direct_velocity = (velocity * gravity_mask).length()
	if direct_velocity < MAX_VELOCITY: return
	direct_velocity /= MAX_VELOCITY
	velocity *= positive_gravity_vector + gravity_mask / direct_velocity


func _wall_handling() -> void:
	if is_on_wall(): velocity -= velocity * gravity_mask * WALL_GRIP


func _move_holder(delta:float) -> void:
	holder.global_position = lerp(holder.global_position, head.global_position, delta * 16)
	holder.rotation.x = lerp_angle(holder.rotation.x, head.rotation.x , delta * 16)
	holder.rotation.y = lerp_angle(holder.rotation.y, head.rotation.y , delta * 16)


func _set_movement_direction() -> void: 
	direction = ((
		input_dir.x * up_direction.cross(head.global_basis.z) + # up x forward = left
		input_dir.y * head.global_basis.z) *
		gravity_mask
	).normalized() # * gravity_mask and normalized => look at floor and move


func set_gravity(new_gravity_vector:Vector3) -> void:
	gravity_vector = new_gravity_vector
	inv_gravity_vector = -gravity_vector
	positive_gravity_vector = new_gravity_vector * new_gravity_vector
	gravity_mask = Vector3.ONE - positive_gravity_vector
	up_direction = -new_gravity_vector


func set_gravity_global(new_gravity_vector:Vector3) -> void:
	current_ps3d_gravity_vector = new_gravity_vector
	Gravity.change_gravity_vector(new_gravity_vector)


func teleport_to_initial_position() -> void:
	global_position = initial_position
	set_velocity.call_deferred(Vector3.ZERO)
