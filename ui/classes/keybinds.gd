extends VBoxContainer

func _ready() -> void:
	var inputs := Utils.get_inputs()
	inputs.keys().map(
		func (x:StringName) -> void:
			var keybind := KeybindButton.new(x, inputs[x][0] if not inputs[x].is_empty() else InputEventMouseButton.new())
			add_child(keybind)
			keybind.set_owner(owner)
	)
