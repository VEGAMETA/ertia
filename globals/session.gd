class_name Session extends ColorRect

@onready var splash_timer : Timer = %Timer
var instances : Array[Control] = []
#
#func _ready() -> void:
	#instances.append_array(get_children(true).filter(func (x:Node) -> bool: return x is Control))
	#instances.map(func (x:Node) -> void: x.visible = false)
	#if not instances: return
	#instances.get(0).set_visible(true)
	#splash_timer.timeout.connect(_on_timeout)
	#splash_timer.start()
func _ready() -> void:
	#queue_free()
	get_tree().create_timer(0.0).timeout.connect(func ()->void:  Menu.menu(); queue_free.call_deferred())
	#get_tree().tree_changed.connect(_lose_scene)
	#Menu.menu.call_deferred()

func _lose_scene(_node:Node) -> void:
	if get_tree() == null: return
	if get_tree().current_scene == null: return
	print(get_tree().current_scene)
	if get_tree().current_scene == self:
		queue_free()
		get_tree().tree_changed.disconnect(_lose_scene)
		get_tree().create_timer(0.5).timeout.connect(Menu.menu)

func _on_timeout() -> void:
	if not instances.size() > 1: return Menu.menu()
	instances.pop_front().set_visible(false)
	instances.get(0).set_visible(true)	
	if instances.size() > 1: splash_timer.start()


func _input(event:InputEvent) -> void:
	if  event.is_action_pressed("ui_cancel") or \
		event.is_action_pressed("ui_accept") or \
		event.is_action_pressed("ui_select"):
		splash_timer.timeout.emit()
