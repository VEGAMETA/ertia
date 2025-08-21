class_name SettingsWindow extends Window

@onready var i18n_button: OptionButton = %L8nButton
@onready var mouse_sens_value: HSlider = %MouseSensValue
@onready var gamepad_sens_value: HSlider = %GamepadSensValue
@onready var fov_value: HSlider = %FOVValue
@onready var network_value: CheckBox = %NetworkValue
@onready var debug_value: CheckBox = %DebugValue

@onready var anisotropic_filtering: OptionButton = %AnisotropicFilteringButton
@onready var shadows: OptionButton = %ShadowsButton
@onready var gamma: HSlider = %GammaValue
@onready var gamma_label: Label = %GammaLabel
@onready var ssao: CheckBox = %SSAOValue
@onready var ssil: CheckBox = %SSILValue
@onready var glow: CheckBox = %GlowValue

@onready var scale_value: HSlider = %ScaleValue
@onready var scale_label: Label = %ScaleLabel
@onready var window_mode: OptionButton = %WindowModeValue
@onready var v_sync: OptionButton = %VSyncValue
@onready var fps: OptionButton = %FpsButton
@onready var phys: OptionButton = %PhysButton

@onready var master_slider: HSlider = %MasterSlider
@onready var master_value: Label = %MasterValue
@onready var music_slider: HSlider = %MusicSlider
@onready var music_value: Label = %MusicValue
@onready var sfx_slider: HSlider = %SfxSlider
@onready var sfx_value: Label = %SfxValue
@onready var voice_slider: HSlider = %VoiceSlider
@onready var voice_value: Label = %VoiceValue
@onready var subtitles_value: CheckBox = %SubtitlesValue
@onready var subtitles_size_value: HSlider = %SubtitlesSizeValue

@onready var controller_type_button: OptionButton = %ControllerTypeButton
@onready var vibration_value: CheckBox = %VibrationValue
@onready var deadzone_value: HSlider = %DeadzoneValue
@onready var deadzone_label: Label = %DeadzoneLabel

@onready var tab_container: TabContainer = $TabContainer

var i18n := {0:"en", 1:"ru"}


func _init() -> void:
	set_flag(Window.FLAG_ALWAYS_ON_TOP, true)


func _ready() -> void:
	set_flag(Window.FLAG_ALWAYS_ON_TOP, true)
	process_mode = Node.PROCESS_MODE_ALWAYS
	close_requested.connect(close)
	set_game()
	set_graphics()
	set_display()
	set_audio()
	set_keybinds()
	set_controller()
	tab_container.current_tab = 0

func _notification(what: int) -> void:
	print(what)

func set_game() -> void:
	i18n_button.get_popup().set_flag(Window.FLAG_ALWAYS_ON_TOP, true)
	mouse_sens_value.set_value(Settings.mouse_sens)
	gamepad_sens_value.set_value(Settings.gamepad_sens)
	fov_value.set_value(Settings.fov)
	subtitles_size_value.set_value(Settings.subtitles_size)
	subtitles_value.set_pressed(Settings.subtitles)
	debug_value.set_pressed(Settings.debug)
	network_value.set_pressed(Settings.network)
	
	i18n_button.item_selected.connect(func (idx:int)->void: TranslationServer.set_locale(i18n.get(idx, "en")))
	mouse_sens_value.value_changed.connect(func (value:float)->void: Settings.mouse_sens = value)
	gamepad_sens_value.value_changed.connect(func (value:float)->void: Settings.gamepad_sens = value)
	fov_value.value_changed.connect(func (value:float)->void: Settings.fov = value)
	subtitles_size_value.value_changed.connect(func (value:float)->void: Settings.subtitles_size = value)
	subtitles_value.toggled.connect(func (value:bool)->void: Settings.subtitles = value)
	debug_value.toggled.connect(func (x:bool)->void: Settings.debug = x)
	network_value.toggled.connect(func (x:bool)->void: Settings.network = x)


func set_graphics() -> void:
	shadows.get_popup().set_flag(Window.FLAG_ALWAYS_ON_TOP, true)
	anisotropic_filtering.get_popup().set_flag(Window.FLAG_ALWAYS_ON_TOP, true)
	shadows.select(Settings.shadows)
	anisotropic_filtering.select(get_tree().get_root().get_anisotropic_filtering_level())
	gamma.set_value(Gamma.get_gamma())
	ssao.set_pressed(Settings.ssao)
	ssil.set_pressed(Settings.ssil)
	glow.set_pressed(Settings.glow)
	shadows.item_selected.connect(Settings.set_shadows.bind(shadows))
	anisotropic_filtering.item_selected.connect(Settings.set_filtering)
	gamma.value_changed.connect(Settings.set_gamma.bind(gamma_label))
	ssao.toggled.connect(func (value:bool)->void: Settings.ssao = value)
	ssil.toggled.connect(func (value:bool)->void: Settings.ssil = value)
	glow.toggled.connect(func (value:bool)->void: Settings.glow = value)


func set_display() -> void:
	window_mode.get_popup().set_flag(Window.FLAG_ALWAYS_ON_TOP, true)
	v_sync.get_popup().set_flag(Window.FLAG_ALWAYS_ON_TOP, true)
	fps.get_popup().set_flag(Window.FLAG_ALWAYS_ON_TOP, true)
	phys.get_popup().set_flag(Window.FLAG_ALWAYS_ON_TOP, true)
	get_tree().get_root().size_changed.connect(func ()->void: window_mode.select(window_mode.get_item_index(DisplayServer.window_get_mode(0))))
	window_mode.select(window_mode.get_item_index(DisplayServer.window_get_mode(0)))
	v_sync.select(v_sync.get_item_index(DisplayServer.window_get_vsync_mode(0)))
	fps.select(fps.get_item_index(Engine.get_max_fps()))
	phys.select(phys.get_item_index(Settings.phys_ticks))
	scale_value.value_changed.connect(Settings.set_scale.bind(scale_label))
	v_sync.item_selected.connect(Settings.set_vsync.bind(v_sync))
	window_mode.item_selected.connect(Settings.set_window_mode.bind(window_mode))
	fps.item_selected.connect(Settings.set_max_fps.bind(fps))
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


func set_keybinds() -> void:
	pass


func set_controller() -> void:
	controller_type_button.get_popup().set_flag(Window.FLAG_ALWAYS_ON_TOP, true)

func _on_toggle(_visible:bool) -> void:
	if _visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Menu"): close()
	else: Globals._input(event)


func close() -> void:
	visible = false
