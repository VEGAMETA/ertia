class_name Player extends BasePlayer

#Save
@export var saved_grabbed_object : RigidBody3D = null
@export var saved_flashlight : bool = false
@export var saved_crouching : bool = false
@export var saved_rotation : Vector3 = Vector3.ZERO

@export var gamepad_sensibility : float = 4.0
@export var gamepad_sensibility_accel : float = gamepad_sensibility * 0.9
@export var new_cam_rotation : Vector2 = Vector2.ZERO

@export var inventory_item : Attackable = null # @export_storage causes constant freezes

@onready var collision_stand : CollisionShape3D = $CollisionStand
@onready var collision_crouch : CollisionShape3D = $CollisionCrouch
@onready var collision_legs : CollisionShape3D = $CollisionLegs

@onready var shape_stand : ShapeCast3D = $ShapeStand
@onready var shape_under : ShapeCast3D = $UnderBottom
@onready var gravity_device : GravityDevice = %GravityDevice
@onready var grabber : GrabberComponent = %Grabber
@onready var croucher : CroucherComponent = %Croucher
@onready var flashlight : FlashlightComponent = %Flashlight
@onready var camera : PlayerCameraComponent = %Camera
@onready var remote_camera : RemoteTransform3D = %RemoteCamera
@onready var remote_camera_menu: RemoteTransform3D = %RemoteCameraMenu
@onready var safe_area : Area3D = %SafeArea
@onready var aim : Node3D = %Aim


func _ready() -> void:
	super()
	if not is_multiplayer_authority(): return
	inventory_item = gravity_device
	camera.current = true
	self.load_save()


func _process(delta:float) -> void:
	aim.rotation.x = lerp_angle(aim.rotation.x, head.rotation.x, delta * 16)
	aim.rotation.y = lerp_angle(aim.rotation.y, head.rotation.y, delta * 16)
	_hadle_rotation(delta)

func _physics_process(delta: float) -> void:
	super(delta)
	print(position, head.position)
	


func load_save() -> void:
	grabber.grabbed_object = saved_grabbed_object
	flashlight.visible = saved_flashlight
	head.rotation = saved_rotation
	holder.rotation = saved_rotation
	if saved_crouching: croucher.crouch(false, false)


func save() -> void:
	saved_grabbed_object = grabber.grabbed_object
	saved_flashlight = flashlight.visible
	saved_crouching = croucher.crouching
	saved_rotation = head.rotation


func _input(event:InputEvent) -> void:
	if not is_multiplayer_authority(): return
	super(event)
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		new_cam_rotation = event.relative
	if event.is_action_pressed("Attack") and not Globals.just_unpaused:
		inventory_item.attack()


func _hadle_rotation(delta:float) -> void:
	if not is_multiplayer_authority(): return
	if new_cam_rotation == Vector2.ZERO:
		new_cam_rotation = Input.get_vector("j_left", "j_right", "j_up", "j_down") * gamepad_sensibility
		if new_cam_rotation.length() > gamepad_sensibility_accel:
			new_cam_rotation *= exp(new_cam_rotation.length() - gamepad_sensibility_accel) / 0.6 + 1
		new_cam_rotation *=  delta * 230
	if Input.is_action_pressed("Alternative") and grabber.grabbed_object:
		grabber.rotate_object()
	else: _handle_camera_rotation()
	new_cam_rotation = Vector2.ZERO


func _handle_camera_rotation() -> void:
	head.rotation.x = clamp(
		head.rotation.x - new_cam_rotation.y * mouse_sensibility, 
		Math.PI_BY_MINUS_2 + DEVIATION, 
		Math.PI_BY_2 - DEVIATION
	)
	head.rotation.y = wrap(head.rotation.y - new_cam_rotation.x * mouse_sensibility, -PI, PI)
	#camera.global_transform = head.get_global_transform_interpolated()
	#%ItemHolder.global_position = head.get_global_transform_interpolated() * Vector3(0.15, -0.175, -0.2)
	#grabber.global_transform = head.get_global_transform_interpolated()
