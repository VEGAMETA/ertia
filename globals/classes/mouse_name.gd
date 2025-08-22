class_name MouseName

static func get_action_name(index: MouseButton) -> String:
	match index:
		MOUSE_BUTTON_LEFT: return "LMB"
		MOUSE_BUTTON_RIGHT: return "RMB"
		MOUSE_BUTTON_MIDDLE: return "MMB"
		MOUSE_BUTTON_WHEEL_LEFT: return "Scroll Left"
		MOUSE_BUTTON_WHEEL_RIGHT: return "Scroll Right"
		MOUSE_BUTTON_WHEEL_DOWN: return "Scroll Down"
		MOUSE_BUTTON_WHEEL_UP: return "Scroll Up"
		MOUSE_BUTTON_XBUTTON1: return "Side Button 1"
		MOUSE_BUTTON_XBUTTON2: return "Side Button 2"
	return "Undefined"
