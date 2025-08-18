class_name SettingsWindow extends Window

@onready var light_preset: OptionButton = %LightButton
@onready var anisotropic_filtering: OptionButton = %AnisotropicFilteringButton

func _ready() -> void:
	always_on_top = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	close_requested.connect(close)
	anisotropic_filtering.get_popup().always_on_top = true
	light_preset.get_popup().always_on_top = true
	anisotropic_filtering.select(get_viewport().get_anisotropic_filtering_level())
	light_preset.item_selected.connect(change_light)
	anisotropic_filtering.item_selected.connect(change_anisotropic_filtering)

func _on_toggle(_visible:bool) -> void:
	if _visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Menu"): close()
	#else: Globals._input(event)

func close() -> void:
	visible = false

func change_anisotropic_filtering(index: Window.AnisotropicFiltering) -> void:
	if index > Window.AnisotropicFiltering.ANISOTROPY_16X or index < 0:
		get_viewport().set_anisotropic_filtering_level(Window.AnisotropicFiltering.ANISOTROPY_MAX) 
	get_viewport().set_anisotropic_filtering_level(index)

func change_light(index: int) -> void:
	var shadow_size := 256 * ((2 ** (index + 1)) if index > 0 else 1 )
	RenderingServer.directional_shadow_atlas_set_size(shadow_size, false)
	RenderingServer.positional_soft_shadow_filter_set_quality(index)
	RenderingServer.viewport_set_positional_shadow_atlas_size(get_viewport_rid(), shadow_size, false)
