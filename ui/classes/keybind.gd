class_name KeybindButton extends HBoxContainer


var label := Label.new()
var button := Button.new()
var bind_name : StringName
var key : InputEvent

func _init(action:StringName, key_: InputEvent) -> void:
	bind_name = action
	key = key_

func _ready() -> void:
	Settings.changing_keybind.connect(toggle_off)
	Settings.keybind_changed.connect(toggle_on)
	Settings.action_erased.connect(reset_name)
	button.toggled.connect(set_keybinding)
	button.set_text(get_key_name())
	button.set_toggle_mode(true)
	button.set_h_size_flags(3)
	button.set_v_size_flags(3)
	label.set_text(bind_name)
	label.set_h_size_flags(3)
	label.set_v_size_flags(3)
	set_h_size_flags(3)
	set_v_size_flags(3)
	add_child(Control.new())
	add_child(label)
	add_child(Control.new())
	add_child(button)
	add_child(Control.new())
	add_theme_constant_override(&"separation", 45)
	set_process_unhandled_input(false)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		bind_action_key(event)
		unchange()


func unchange() -> void:
	if not Settings.changing_keybind.is_connected(toggle_off):
		Settings.changing_keybind.connect(toggle_off)
	Settings.keybind_changed.emit()
	button.set_pressed(false)
	

func toggle_off() -> void:
	set_process_unhandled_input(false)
	button.set_toggle_mode(false)
	button.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)

func toggle_on() -> void:
	set_process_unhandled_input(false)
	button.set_toggle_mode(true)
	button.set_mouse_filter(Control.MOUSE_FILTER_STOP)

func set_keybinding(pressed:bool) -> void:
	if pressed:
		if Settings.changing_keybind.is_connected(toggle_off):
			Settings.changing_keybind.disconnect(toggle_off)
		Settings.changing_keybind.emit()
		button.set_text("...")
		set_process_unhandled_input.call_deferred(true)
		owner.set_process_input(false)
		button.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	else:
		if not Settings.changing_keybind.is_connected(toggle_off):
			Settings.changing_keybind.connect(toggle_off)
		button.set_text.call_deferred(get_key_name())
		set_process_unhandled_input(false)
		owner.set_process_input(true)
		button.set_mouse_filter(Control.MOUSE_FILTER_STOP)


func get_key_name() -> String:
	if key is InputEventKey: return OS.get_keycode_string(key.get_physical_keycode_with_modifiers())
	elif key is InputEventMouseButton: return MouseName.get_action_name(key.get_button_index())
	return "Undefined"

func bind_action_key(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.get_physical_keycode_with_modifiers() in [KEY_QUOTELEFT, KEY_ESCAPE]:
			return
	if key != null:
		InputMap.action_erase_event(bind_name, key)
	check_duplicates(event)
	InputMap.action_add_event(bind_name, event)
	key = event

func check_duplicates(event: InputEvent) -> void:
	InputMap.action_get_events(bind_name).filter(func (x:InputEvent)->bool: return x is InputEventKey or x is InputEventMouseButton)
	var inputs := Utils.get_inputs()
	for action : StringName in inputs.keys():
		if action == bind_name: continue
		if not InputMap.action_has_event(action, event): continue
		InputMap.action_erase_event(action, event)
		for key_ : InputEvent in inputs.get(action, []):
			if key_.get_class() != event.get_class(): return
			if  !((key_ is InputEventKey and key_.get_physical_keycode_with_modifiers() == event.get_physical_keycode_with_modifiers()) \
			or (key_ is InputEventMouseButton and key_.get_button_index() == event.get_button_index())): continue
			InputMap.action_erase_event(action, key_)
			Settings.action_erased.emit(key_)

func reset_name(event:InputEvent) -> void:
	if key != event: return
	InputMap.action_erase_event(bind_name, key)
	key = null
	button.set_text(get_key_name())
