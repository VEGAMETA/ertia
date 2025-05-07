class_name SafeAreaComponent extends Area3D

var _inv_velocity_multiplyer : float = -0.01
var _new_angular_velocity : Vector3 = Vector3(1.3, 3.2, 3.1)

func _ready() -> void:
	if owner is not BasePlayer: return
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta):
	global_rotation = Vector3.ZERO

func _on_body_entered(body:Node3D) -> void:
	if body is not RigidBody3D: return
	body.linear_velocity *= _inv_velocity_multiplyer
	body.angular_velocity = _new_angular_velocity
	print(owner.collision_mask, " ", Globals.Collisions.DYNAMIC)
	owner.collision_mask &= Globals.inv_collision(Globals.Collisions.DYNAMIC) 
	print(owner.collision_mask, " ", Globals.Collisions.DYNAMIC)
	
func _on_body_exited(_body:Node3D) -> void:
	if get_overlapping_bodies().any(func(x): return x is RigidBody3D): return
	print(owner.collision_mask, " ", Globals.Collisions.DYNAMIC)
	owner.collision_mask |= Globals.Collisions.DYNAMIC
