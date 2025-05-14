class_name CoyoteTimerComponent extends Timer

@onready var jumper: JumpComponent = get_parent()
@onready var player: BasePlayer = owner

@export var timer_time : float = 0.187
@export var jumped : bool = true
@export var falling : bool = true

func _ready():
	set_wait_time(timer_time)
	timeout.connect(_on_timeout)
	jumper.jump.connect(jump)

func jump():
	jumped = true
	falling = true
	stop()

func _physics_process(_delta) -> void:
	if player.is_on_floor():
		if not falling: jumped = false
		if not is_stopped(): stop()
	elif not jumped:
		if not falling and is_stopped(): start()
		if not is_stopped(): jumper.can_jump = true
	falling = player.is_on_floor()

func _on_timeout():
	jump()
	jumper.can_jump = false
	
