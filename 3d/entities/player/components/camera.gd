class_name PlayerCameraComponent extends Camera3D

const CAMERA_RUN_FOV : float = 100.0 # 108 is trueee
const CAMERA_DEFAULT_FOV : float = 90.0
const CAMERA_ZOOMED_FOV : float = 45.0

var fov_tween : Tween
var position_tween : Tween
var hud_tween : Tween
var debug_view_list : Array[int] = [1, 3, 4, 5, 26, 0]
var trasns_time : float = 0.0
var max_alpha : float = 0.0
@export var zoomed : bool = false

@onready var player : Player = owner
@onready var head : Node3D = player.head

func _notification(what) -> void:
	match what:
		NOTIFICATION_PAUSED: zoom_out_fov()

func _ready() -> void:
	handle_first_person()

func _process(_delta) -> void:
	#player.gravitator.rotator_head.rotation = head.global_rotation
	if not zoomed and (fov_tween == null or (fov_tween and not fov_tween.is_running())):
		if player.velocity.length() > 7.9: run_fov()
		else: run_to_default_fov()

func _unhandled_input(event) -> void:
	if event.is_action_pressed("Zoom") and not player.running and not zoomed: zoom_in_fov()
	if event.is_action_released("Zoom") and zoomed: zoom_out_fov()

func play_fov_animation(new_fov, time=1.0, trans=Tween.TRANS_LINEAR) -> void:
	if fov_tween: fov_tween.kill()
	fov_tween = create_tween()
	fov_tween.set_trans(trans)
	fov_tween.tween_property(self, "fov", new_fov, 0.4 * time)

func play_position_animation(new_pos, time:float=1.0):
	if position_tween: position_tween.kill()
	position_tween = create_tween()
	position_tween.set_trans(Tween.TRANS_SINE)
	position_tween.tween_property(player.head, "position", new_pos, 0.2 * time)

func run_fov() -> void:
	play_fov_animation(CAMERA_RUN_FOV, \
	(CAMERA_RUN_FOV-fov) / (CAMERA_RUN_FOV-CAMERA_DEFAULT_FOV), \
	Tween.TRANS_SINE)

func run_to_default_fov() -> void:
	play_fov_animation(CAMERA_DEFAULT_FOV, \
	(fov-CAMERA_DEFAULT_FOV) / (CAMERA_RUN_FOV-CAMERA_DEFAULT_FOV),\
	Tween.TRANS_SINE)

func zoom_in_fov() -> void:
	zoomed = true
	trasns_time = (fov-CAMERA_ZOOMED_FOV)/(CAMERA_DEFAULT_FOV-CAMERA_ZOOMED_FOV)
	play_fov_animation(CAMERA_ZOOMED_FOV, trasns_time, Tween.TRANS_EXPO)

func zoom_out_fov() -> void:
	zoomed = false
	trasns_time = (CAMERA_DEFAULT_FOV-fov)/(CAMERA_DEFAULT_FOV-CAMERA_ZOOMED_FOV)
	play_fov_animation(CAMERA_DEFAULT_FOV, trasns_time, Tween.TRANS_EXPO)
	
func handle_first_person() -> void:
	position.z = 0.0 if player.firstperson else 4.0

func _on_croucher_crouched(not_saved):
	play_position_animation(Vector3(0.0, -1.0, 0.0), int(not_saved)*(1+player.head.position.y))

func _on_croucher_uncrouched():
	if player.camera.position != player.head.position:
		play_position_animation(Vector3.ZERO, 1 - player.head.position.y)
