class_name InboundArea3D extends Area3D

func _ready():
	collision_mask = Globals.Collisions.PLAYER
	body_exited.connect(restore_player)
	
	

func restore_player(body:Node3D):
	if body is BasePlayer:
		body.teleport_to_initial_position()
