extends Node

signal mouse_sens_changed(value:float)
signal gamepad_sens_changed(value:float)
signal network_toggle(visible:bool)
signal fov_changed(value:float)
signal subtitles_changed(value:bool)
signal subtitles_size_changed(value:float)

signal changing_keybind
signal keybind_changed
signal action_erased(event:InputEvent)

var debug : bool = OS.is_debug_build()
var network: bool = false:
	set(v):
		network = v
		network_toggle.emit(v)


@export var subtitles : bool = false:
	set(v):
		subtitles = v
		subtitles_changed.emit(v)
@export var subtitles_size : float = 14.0:
	set(v):
		subtitles_size = v
		subtitles_size_changed.emit(v)
@export var mouse_sens : float = 1.0:
	set(v):
		mouse_sens = v
		mouse_sens_changed.emit(v)
@export var gamepad_sens : float = 1.0:
	set(v):
		gamepad_sens = v
		gamepad_sens_changed.emit(v)
@export var fov : float = 100:
	set(v):
		fov = v
		fov_changed.emit(v)


var i18n := {0:"en", 1:"ru"}
var locale := i18n.find_key(OS.get_locale_language()) as int

@export var shadows : int = 3
@export var gamma : float = 1.0:
	set(v):
		gamma = v
		Gamma.set_gamma(v)

@export var ssao : bool = false:
	set(v):
		ssao = v
		set_environment()
@export var ssil : bool = false:
	set(v):
		ssil = v
		set_environment()
@export var glow : bool = true:
	set(v):
		glow = v
		set_environment()

@export var current_window_mode : DisplayServer.WindowMode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
@export var max_fps : int = 0
@export var phys_ticks : int = 0

var controller_inputs : Array[StringName] = [&"Forward", &"Backward", &"StrafeLeft", &"StrafeRight", &"j_up", &"j_down", &"j_left", &"j_right"]

@export var deadzone : float = 0.2:
	set(v):
		deadzone = v
		for input in controller_inputs:
			InputMap.action_set_deadzone(input, v)

@export var vibration : bool = true

func _ready() -> void:
	_initalize.call_deferred()

func _initalize() -> void:
	get_tree().tree_changed.connect(set_environment.call_deferred)

func get_settings() -> void:
	pass
	
func set_settings() -> void:
	pass

# Graphics
func set_environment() -> void:
	if get_tree() == null: return
	if get_tree().current_scene == null: return
	for world_env in get_tree().current_scene.get_children():
		if world_env is WorldEnvironment:
			world_env.environment.ssao_enabled = ssao
			world_env.environment.ssao_enabled = ssao
			world_env.environment.glow_enabled = glow

func set_filtering(idx:Window.AnisotropicFiltering) -> void:
		if idx > Window.AnisotropicFiltering.ANISOTROPY_16X or idx < 0:
			get_tree().get_root().set_anisotropic_filtering_level(Window.AnisotropicFiltering.ANISOTROPY_MAX)
		get_tree().get_root().set_anisotropic_filtering_level(idx)

func set_shadows(idx:int, shadows_button:OptionButton) -> void:
	var shadow_size := shadows_button.get_item_id(idx)
	RenderingServer.directional_shadow_atlas_set_size(shadow_size, false)
	RenderingServer.viewport_set_positional_shadow_atlas_size(get_tree().get_root().get_viewport_rid(), shadow_size, false)
	RenderingServer.positional_soft_shadow_filter_set_quality(idx)
	RenderingServer.directional_soft_shadow_filter_set_quality(idx)
	shadows = idx

func set_gamma(value:float, gamma_label:Label) -> void:
	gamma = value
	gamma_label.set_text("%.2f" % value)


# Display

func set_scale(value:float, label:Label) -> void:
	RenderingServer.viewport_set_scaling_3d_scale(get_tree().get_root().get_viewport_rid(), value)
	label.set_text("%.2f" % value)

func set_vsync(idx:int, vsync_button:OptionButton) -> void: 
	DisplayServer.window_set_vsync_mode(vsync_button.get_item_id(idx))

func set_window_mode(idx:int, window_mode_button:OptionButton) -> void: 
	DisplayServer.window_set_mode(window_mode_button.get_item_id(idx))
	current_window_mode = DisplayServer.window_get_mode(0)

func set_max_fps(idx:int, fps_button:OptionButton) -> void:
	max_fps = fps_button.get_item_id(idx)
	Engine.set_max_fps(max_fps)
	Globals.reset_physics()

func set_phys_ticks(idx:int, phys_button:OptionButton) -> void: 
	phys_ticks = phys_button.get_item_id(idx)
	if idx == 0: return Globals.reset_physics()
	Engine.set_physics_ticks_per_second(phys_ticks)
	Globals.reset_physics()

# Audio

func set_bus_volume(value:float, button:HSlider, label:Label, bus_name:StringName) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(bus_name), value)
	label.set_text(String.num(button.get_value() * 100, 0) + "%")

# Controls

func set_deadzone(value:float, label:Label) -> void:
	deadzone = value
	label.set_text("%.2f" % value)
