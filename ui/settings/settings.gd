class_name SettingsWindow extends Window

@onready var resolution: OptionButton = %ResolutionButton
@onready var window_mode: OptionButton = %WindowModeValue
@onready var v_sync: OptionButton = %VSyncValue
@onready var fps: OptionButton = %FpsButton
@onready var phys: OptionButton = %PhysButton

@onready var shadows: OptionButton = %ShadowsButton
@onready var anisotropic_filtering: OptionButton = %AnisotropicFilteringButton

@onready var master_slider: HSlider = %MasterSlider
@onready var master_value: Label = %MasterValue
@onready var music_slider: HSlider = %MusicSlider
@onready var music_value: Label = %MusicValue
@onready var sfx_slider: HSlider = %SfxSlider
@onready var sfx_value: Label = %SfxValue
@onready var voice_slider: HSlider = %VoiceSlider
@onready var voice_value: Label = %VoiceValue

func _ready() -> void:
	always_on_top = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	close_requested.connect(close)
	set_graphics()
	set_display()
	set_audio()


func set_graphics() -> void:
	shadows.get_popup().always_on_top = true
	anisotropic_filtering.get_popup().always_on_top = true
	anisotropic_filtering.select(get_tree().get_root().get_anisotropic_filtering_level())
	shadows.item_selected.connect(Settings.set_shadows.bind(shadows))
	anisotropic_filtering.item_selected.connect(Settings.set_filtering)

	
func set_display() -> void:
	resolution.get_popup().always_on_top = true
	window_mode.get_popup().always_on_top = true
	v_sync.get_popup().always_on_top = true
	fps.get_popup().always_on_top = true
	phys.get_popup().always_on_top = true
	
	get_tree().get_root().size_changed.connect(func ()->void: window_mode.select(window_mode.get_item_index(DisplayServer.window_get_mode(0))))
	
	resolution.set_item_text(0, str(get_tree().root.get_size().x) + "x" + str(get_tree().root.get_size().y) + " (current)")
	resolution.select(resolution.get_item_index(0))
	window_mode.select(window_mode.get_item_index(DisplayServer.window_get_mode(0)))
	v_sync.select(v_sync.get_item_index(DisplayServer.window_get_vsync_mode(0)))
	fps.select(fps.get_item_index(Engine.get_max_fps()))
	phys.select(phys.get_item_index(0 if Engine.get_physics_ticks_per_second() == int(DisplayServer.screen_get_refresh_rate()) else Engine.get_physics_ticks_per_second() ))
	
	v_sync.item_selected.connect(Settings.set_vsync.bind(v_sync))
	window_mode.item_selected.connect(Settings.set_window_mode.bind(window_mode))
	fps.item_selected.connect(Settings.set_max_fps.bind(phys, fps))
	phys.item_selected.connect(Settings.set_phys_ticks.bind(phys))


func set_audio() -> void:
	master_slider.value_changed.connect(Settings.set_bus_volume.bind(master_slider, master_value, &"Master"))
	music_slider.value_changed.connect(Settings.set_bus_volume.bind(music_slider, music_value, &"Music"))
	sfx_slider.value_changed.connect(Settings.set_bus_volume.bind(sfx_slider, sfx_value, &"Sfx"))
	voice_slider.value_changed.connect(Settings.set_bus_volume.bind(voice_slider, voice_value, &"Voice"))
	master_slider.set_value(AudioServer.get_bus_volume_linear(AudioServer.get_bus_index(&"Master")))
	music_slider.set_value(AudioServer.get_bus_volume_linear(AudioServer.get_bus_index(&"Music")))
	sfx_slider.set_value(AudioServer.get_bus_volume_linear(AudioServer.get_bus_index(&"Sfx")))
	voice_slider.set_value(AudioServer.get_bus_volume_linear(AudioServer.get_bus_index(&"Voice")))


func _on_toggle(_visible:bool) -> void:
	if _visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Menu"): close()
	else: Globals._input(event)

func close() -> void:
	visible = false
