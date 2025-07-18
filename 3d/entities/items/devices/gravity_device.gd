class_name GravityDevice extends Attackable

enum DIRECTIONS{
	TOP,
	BOTTOM,
	LEFT,
	RIGHT,
	FRONT,
	REAR
}

@export var old_vision_position_global : Vector3
@export var old_head_position_global : Vector3
@export var old_head_rotation_global : Vector3
@export var old_head_rotation_local : Vector3
@export var new_head_rotation_global : Vector3
@export_custom(PROPERTY_HINT_NONE, "") 
var gravity_direction : GravityDirection
@export var new_gravity_vector : Vector3 = Vector3.MODEL_BOTTOM
@export var new_rotation : Vector3
@export var x : float
@export var y : float
@export var garvity_area : Area3D

@export var avalible_gravities : Dictionary[DIRECTIONS, bool] = {
	DIRECTIONS.TOP: true,
	DIRECTIONS.BOTTOM: true,
	DIRECTIONS.LEFT: true,
	DIRECTIONS.RIGHT: true,
	DIRECTIONS.FRONT: true,
	DIRECTIONS.REAR: true,
}

@onready var sprite : Sprite3D = %Sprite
@onready var rotator : SubViewport = %Rotator
@onready var rotator_head : Node3D = rotator.find_child("Center")
@onready var player : BasePlayer = owner

var vibration_timer : Timer = Timer.new()

var tween: Tween

func _ready() -> void:
	_initialize()

func _initialize() -> void:
	if player.gravity_vector != Vector3.ZERO:
		new_gravity_vector = player.gravity_vector
		gravity_direction = GravityDirections.by_vector.get(new_gravity_vector, GravityDirections.ZERO)
	if player.current_ps3d_gravity_vector == Vector3.ZERO: 
		player.current_ps3d_gravity_vector = new_gravity_vector
	player.gravity = Gravity.gravity
	await get_tree().physics_frame
	player.gravity_area_watcher.force_shapecast_update()
	watch_areas()
	set_gravity_vector_player()
	set_gravity_ps3d()
	add_child(vibration_timer)
	vibration_timer.timeout.connect(prevent_vibration)


func attack() -> void:
	if Input.is_action_pressed("Alternative"): return
	change_gravity.rpc(get_direction().rotation_vector)

func _process(_delta:float) -> void:
	rotator_head.rotation = player.head.global_rotation

func _physics_process(_delta:float) -> void:
	watch_and_change_gravity()

func watch_and_change_gravity() -> void:
	watch_areas()
	if new_gravity_vector == player.gravity_vector: return
	change_gravity(new_gravity_vector)

func watch_areas() -> void:
	if not player.gravity_area_watcher.is_colliding(): 
		new_gravity_vector = Gravity.get_gravity_vector()
		return
	new_gravity_vector = Vector3.ZERO
	for area in range(player.gravity_area_watcher.get_collision_count()):
		garvity_area = player.gravity_area_watcher.get_collider(area)
		if not garvity_area is GravityArea3D: continue 
		new_gravity_vector += garvity_area.gravity_direction
	if new_gravity_vector == Vector3.ZERO: return
	new_gravity_vector = new_gravity_vector.normalized()


@rpc("authority", "call_local", "reliable")
func change_gravity(direction:Vector3) -> void:
	gravity_direction = GravityDirections.by_vector.get(direction, GravityDirections.ZERO)
	new_gravity_vector = gravity_direction.rotation_vector
	new_rotation = gravity_direction.body_rotation
	if not _validate_area_direction(): return
	set_hud()
	if new_gravity_vector != player.gravity_vector:
		rotation_correction()
		set_gravity()
		Input.start_joy_vibration(1, 0.8, 0.95, 0.17)
		vibration_timer.start(0.5)

func _validate_area_direction() -> bool:
	if not player.gravity_area_watcher.is_colliding(): return true
	for area in range(player.gravity_area_watcher.get_collision_count()):
		garvity_area = player.gravity_area_watcher.get_collider(area)
		if not garvity_area is GravityArea3D: continue
		if not garvity_area.avalible_gravities & gravity_direction.flag: return false
	return true

func get_direction() -> GravityDirection:
	x = player.head.global_rotation.x
	y = player.head.global_rotation.y
	return (
		GravityDirections.TOP if x > Math.PI_BY_4
		else GravityDirections.BOTTOM if x < Math.PI_BY_MINUS_4
		else GravityDirections.FRONT if -abs(y) <= Math.PI_MINUS_PI_BY_MINUS_4
		else GravityDirections.REAR if abs(y) <= Math.PI_BY_4
		else GravityDirections.LEFT if Math.PI_BY_MINUS_4 > y and y > Math.PI_MINUS_PI_BY_MINUS_4
		else GravityDirections.RIGHT if Math.PI_MINUS_PI_BY_4 > y and y > Math.PI_BY_4
		else gravity_direction
	)


func set_hud() -> void: 
	pass

func rotation_correction() -> void:
	old_head_rotation_global = player.head.global_rotation
	old_head_position_global = player.head.global_position
	old_vision_position_global = player.vision.global_position
	player.global_rotation = new_rotation
	position_correction()
	camera_correction()
	player.head.global_rotation = old_head_rotation_global

func camera_correction() -> void:
	#if not player.noclip: return
	if (-new_gravity_vector).cross(old_vision_position_global-old_head_position_global).is_zero_approx(): return
	player.head.look_at_from_position(old_head_position_global, old_vision_position_global, -new_gravity_vector)
	new_head_rotation_global = player.head.global_rotation
	if tween: tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(player.head, "global_rotation", new_head_rotation_global, 0.15 + (new_head_rotation_global - old_head_rotation_global).length()*0.0625)

func position_correction() -> void:
	if player.croucher.crouching:
		player.position += player.gravity_vector - new_gravity_vector
		return
	await get_tree().physics_frame
	player.shape_stand.force_shapecast_update()
	if player.shape_stand.is_colliding():
		player.global_position -= new_gravity_vector
		player.croucher.wish_crouch = true
		player.croucher.crouch(true)
		player.croucher.wish_uncrouch = true


## Sets gravity vector
func set_gravity() -> void:
	set_gravity_vector_player()
	set_gravity_vector_global()

func set_gravity_vector_player() -> void:
	player.set_gravity(new_gravity_vector)
	
func set_gravity_vector_global() -> void:
	if not player.gravity_area_watcher.is_colliding():
		player.current_ps3d_gravity_vector = new_gravity_vector
		return Gravity.change_gravity_vector(new_gravity_vector)

	for area in range(player.gravity_area_watcher.get_collision_count()):
		garvity_area = player.gravity_area_watcher.get_collider(area)
		if not garvity_area is GravityArea3D: continue 
		garvity_area.gravity_direction = new_gravity_vector
		garvity_area.change_gravity(new_gravity_vector)
		garvity_area.set_color()
		Gravity.change_gravity.emit(new_gravity_vector)

func set_gravity_ps3d() -> void:
	Gravity.change_gravity_vector(player.current_ps3d_gravity_vector)

func prevent_vibration() -> void:
	Input.stop_joy_vibration(1)
