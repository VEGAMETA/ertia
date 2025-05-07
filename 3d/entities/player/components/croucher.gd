class_name CroucherComponent extends Node

@export var wish_crouch : bool = false
@export var wish_uncrouch : bool = true
@export var crouching : bool = false
@onready var player : Player = owner

signal crouched(not_saved:bool)
signal uncrouched

func _notification(what) -> void:
	match what:
		NOTIFICATION_PAUSED:
			if crouching: wish_uncrouch = true

func _set_walk() -> void:
	if crouching:
		if player.walking: return
		player.walking = true
	else:
		if Input.is_action_pressed("Walk"): return
		player.walking = false

func _ready() -> void:
	crouched.connect(_on_crouch)
	uncrouched.connect(_on_uncrouch)
	if player.saved_crouching:
		wish_crouch = true
		crouch.call_deferred(false, false)

func _input(_event) -> void:
	if crouching: wish_uncrouch = not Input.is_action_pressed("Crouch")
	else: wish_crouch = Input.is_action_pressed("Crouch")

func _physics_process(_delta) -> void:
	if player.is_on_floor(): restore_crouch()
	else: crouch_in_air()
	crouch()
	uncrouch()
	_set_walk()

func crouch(gravitating = false, not_saved = true) -> void:
	if not wish_crouch: return
	if gravitating: player.head.position = player.collision_crouch.position
	crouched.emit(not_saved)

func uncrouch() -> void:
	if not wish_uncrouch or wish_crouch: return
	if not player.is_on_floor() or player.shape_stand.is_colliding(): return
	uncrouched.emit()

func crouch_in_air() -> void:
	if player.collision_crouch.position.y != 0.0: return
	player.shape_stand.position.y = 0.5
	player.shape_stand.force_update_transform()
	player.shape_stand.force_shapecast_update()
	var was_colliding = player.shape_stand.is_colliding()
	player.shape_stand.position.y = -0.5
	player.shape_stand.force_update_transform()
	player.shape_stand.force_shapecast_update()
	if player.shape_stand.is_colliding() and was_colliding and not crouching: wish_crouch = true
	if wish_crouch and not crouching:
		player.collision_legs.position.y = player.collision_crouch.position.y - 0.25
		_on_crouch(false)
	elif wish_uncrouch and not player.shape_stand.is_colliding():
		player.collision_legs.position.y = -1.25
		_on_uncrouch()

func restore_crouch() -> void:
	if player.collision_crouch.position.y != 0.0: return
	player.collision_crouch.position.y = -1.0
	player.collision_legs.position.y = player.collision_crouch.position.y - 0.25
	player.shape_stand.force_shapecast_update()
	if not crouching:
		player.collision_legs.position.y = -1.25
		return
	player.global_position -= player.gravity_vector
	player.head.position.y = -1.0

func _on_crouch(_not_saved:bool):
	player.collision_stand.disabled = true
	crouching = true
	wish_crouch = false

func _on_uncrouch():
	player.collision_stand.disabled = false
	crouching = false
	wish_uncrouch = false
