
extends Node
@export var ssao : bool = false
@export var ssil : bool = false
@export var glow : bool = true

func _ready() -> void:
	get_tree().tree_changed.connect(set_environment)

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
	RenderingServer.viewport_set_positional_shadow_atlas_size(get_tree().root.get_viewport_rid(), shadow_size, false)
	RenderingServer.positional_soft_shadow_filter_set_quality(idx)

# Display

func set_resolution(value:String) -> void:
	var resolution = value.split("x")
	if resolution.size() < 2: return
	get_tree().root.set_size(Vector2i(int(resolution[0]), int(resolution[1])))

func set_vsync(idx:int, vsync_button:OptionButton) -> void: 
	DisplayServer.window_set_vsync_mode(vsync_button.get_item_id(idx))

func set_window_mode(idx:int, window_mode_button:OptionButton) -> void: 
	DisplayServer.window_set_mode(window_mode_button.get_item_id(idx))

func set_max_fps(idx:int, phys_button:OptionButton, fps_button:OptionButton) -> void:
	Engine.set_max_fps(fps_button.get_item_id(idx))
	if phys_button.selected == 0: Globals.reset_physics()

func set_phys_ticks(idx:int, phys_button:OptionButton) -> void: 
	if idx == 0: return Globals.reset_physics()
	Engine.set_physics_ticks_per_second(phys_button.get_item_id(idx))

# Audio

func set_bus_volume(value:float, button:HSlider, label:Label, bus_name:StringName) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(bus_name), value)
	label.set_text(String.num(button.get_value() * 100, 0) + "%")
