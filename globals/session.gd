class_name Session extends Control

@onready var splash_timer : Timer = %Timer
var instances : Array[Control] = []


func _ready() -> void:
	instances.append_array(get_children(true).filter(func (x:Node) -> bool: return x is Control))
	instances.map(func (x:Node) -> void: x.visible = false)
	if not instances: return
	instances.get(0).set_visible(true)
	splash_timer.timeout.connect(_on_timeout)
	splash_timer.start()


func _on_timeout() -> void:
	if not instances.size() > 1: return Menu.menu()
	instances.pop_front().set_visible(false)
	instances.get(0).set_visible(true)	
	if instances.size() > 1: splash_timer.start()


func _input(event:InputEvent) -> void:
	if 	event.is_action_pressed("ui_cancel") or \
		event.is_action_pressed("ui_accept") or \
		event.is_action_pressed("ui_select"):
		splash_timer.timeout.emit()
