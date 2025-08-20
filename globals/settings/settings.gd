extends Node

signal mouse_sens_changed(value:float)
signal gamepad_sens_changed(value:float)

var debug : bool = OS.is_debug_build()
var network: bool = false:
	set(v):
		network = v
		Menu.network_toggle.emit(v)

@export var ssao : bool = false
@export var ssil : bool = false
@export var glow : bool = true
@export var gamma : float = 1.0
@export var shadows : int = 3
@export var mouse_sens : float = 1.0
@export var gamepad_sens : float = 1.0
@export var ticks : int = 0
@export var current_window_mode : DisplayServer.WindowMode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN


func _ready() -> void:
	_initalize.call_deferred()

func _initalize() -> void:
	get_tree().tree_changed.connect(set_environment.call_deferred)

func get_settings() -> void:
	pass
	
func set_settings() -> void:
	pass

# Game
func set_sens(value:float, gamepad:bool=false) -> void:
	if gamepad: 
		gamepad_sens = value
		gamepad_sens_changed.emit(value)
	else:
		mouse_sens = value
		mouse_sens_changed.emit(value)

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
	Gamma.set_gamma(value)
	gamma_label.set_text("%.2f" % value)

func set_ssao(value:bool) -> void:
	ssao = value
	set_environment()

func set_ssil(value:bool) -> void:
	ssil = value
	set_environment()

func set_glow(value:bool) -> void:
	glow = value
	set_environment()


# Display

func set_scale(value:float, scale_label:Label) -> void:
	RenderingServer.viewport_set_scaling_3d_scale(get_tree().get_root().get_viewport_rid(), value)
	scale_label.set_text("%.2f" % value)

func set_resolution(idx:int, resolution_button:OptionButton) -> void:
	var resolution := resolution_button.get_item_text(idx).split("x")
	#get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	#get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	if resolution.size() < 2: return get_tree().root.reset_size()
	get_tree().root.set_size(Vector2i(int(resolution[0]), int(resolution[1])))
	DisplayServer.window_set_mode(current_window_mode)

func set_vsync(idx:int, vsync_button:OptionButton) -> void: 
	DisplayServer.window_set_vsync_mode(vsync_button.get_item_id(idx))

func set_window_mode(idx:int, window_mode_button:OptionButton) -> void: 
	DisplayServer.window_set_mode(window_mode_button.get_item_id(idx))
	current_window_mode = DisplayServer.window_get_mode(0)

func set_max_fps(idx:int, phys_button:OptionButton, fps_button:OptionButton) -> void:
	Engine.set_max_fps(fps_button.get_item_id(idx))
	Globals.reset_physics()

func set_phys_ticks(idx:int, phys_button:OptionButton) -> void: 
	ticks = phys_button.get_item_id(idx)
	if idx == 0: return Globals.reset_physics()
	Engine.set_physics_ticks_per_second(ticks)
	Globals.reset_physics()

# Audio

func set_bus_volume(value:float, button:HSlider, label:Label, bus_name:StringName) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(bus_name), value)
	label.set_text(String.num(button.get_value() * 100, 0) + "%")
