extends Camera3D

@onready var camera : PlayerCameraComponent = %Camera
@onready var datamosh_viewport : SubViewport = %Datamosh


func _ready() -> void:
	datamosh_viewport.set_size(get_window().get_size())
	get_window().size_changed.connect(func () -> void: 
		datamosh_viewport.set_size(get_window().get_size())
	)

func _process(_delta: float) -> void:
	fov = camera.fov
