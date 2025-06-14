class_name GrabberComponent extends Node3D

const PULL_FORCE : float = 10.0
const THROW_FORCE : float = 5.0

@export_storage var grabbed_object : RigidBody3D
@export var grabbed_zoom : float
@export var grab_ray_collider : Node
@export var throw : bool

@onready var grab_ray : RayCast3D = %Grab
@onready var hand : Marker3D = %Hand
@onready var grabbed_body : StaticBody3D = %GrabbedBody
@onready var joint: Generic6DOFJoint3D = %GrabJoint
@onready var player : BasePlayer = owner


func _ready() -> void:
	if player.saved_grabbed_object:
		grabbed_object = player.saved_grabbed_object
		joint.set_node_b.call_deferred(grabbed_object.get_path()) # CALL DEFERED TO SAVE ROTATION !!!

func _process(_delta) -> void:
	if check_grabbed_object():
		pull_object()
		zoom_object()
	check_if_floor_is_not_gravity_object()

func _input(event:InputEvent) -> void:
	input.rpc(event)

@rpc("authority", "call_local", "reliable")
func input(event:InputEvent) -> void:
	if event.is_action_pressed("Interract"): interract()
	if Input.is_action_pressed("Alternative") and Input.is_action_pressed("Attack"):
		throw = true
		ungrab_object()

func interract() -> void:
	if grab(): return

###########################
### Object Interraction ###
###########################

func grab() -> bool:
	grab_ray_collider = grab_ray.get_collider()
	if grab_ray_collider == null and not grabbed_object: return false
	if grab_ray_collider == null: ungrab_object()
	if is_instance_of(grab_ray_collider, GravityObject) and not grabbed_object:
		grab_object(grab_ray_collider)
		return true
	ungrab_object()
	return false

func pull_object() -> void:
	if grabbed_object == null: return
	grabbed_object.set_linear_velocity((PULL_FORCE + PULL_FORCE*int(player.running)) * (grabbed_body.global_position - grabbed_object.global_position))

func rotate_object() -> void:
	grabbed_body.rotation.x += player.new_cam_rotation.y * player.mouse_sensibility * 0.5
	grabbed_body.rotation.y += player.new_cam_rotation.x * player.mouse_sensibility * 0.5
	grabbed_body.rotation.x = wrap(grabbed_body.rotation.x, 0, PI*2)
	grabbed_body.rotation.y = wrap(grabbed_body.rotation.y, 0, PI*2)

func zoom_object() -> void:
	if grabbed_object == null: return
	grabbed_zoom = grabbed_body.position.z + \
	(int(Input.is_action_just_pressed("ZoomOut")) - \
	int(Input.is_action_just_pressed("ZoomIn"))) * -0.1
	grabbed_body.position.z = clamp(grabbed_zoom, -2.5, -1.5)

func grab_object(object:RigidBody3D) -> void:
	if grabbed_object != null: return ungrab_object()
	for collision in player.shape_under.collision_result:
		if collision.get("collider") == object: return
	grabbed_object = object
	joint.set_node_b(grabbed_object.get_path())

func ungrab_object() -> void:
	if grabbed_object == null: return
	grabbed_object.linear_velocity /= 8.0 
	grabbed_object.angular_velocity /= 25.0
	if throw: 
		grabbed_object.apply_central_impulse((THROW_FORCE + grabbed_object.mass * 2.0) * (grabbed_object.global_position - player.global_position))
		throw = false
	grabbed_object = null
	joint.set_node_b(joint.get_path())
	grabbed_body.rotation = Vector3.ZERO
	grabbed_body.position.z = -2.0

func check_grabbed_object() -> bool:
	if grabbed_object == null: return false
	if not grabbed_object.is_inside_tree(): 
		grabbed_object = null
		return false
	if player.is_on_floor() and grabbed_object.linear_velocity.length() + grabbed_object.angular_velocity.length() > 30.0:
		ungrab_object()
		return false
	return true

###################################################################
### Checks if gravity object is under the player to prevent bug ###
###################################################################
func check_if_floor_is_not_gravity_object() -> bool:
	if not check_grabbed_object(): return true
	if grabbed_object.sleeping: return true
	if player.shape_under.collision_result.any(
		func (collision): 
			return collision.get("collider") == grabbed_object
	):
		ungrab_object()
		return false
	return true
	
