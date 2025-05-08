@tool
extends MeshInstance3D

var rotator_vec : Vector3 = Vector3.ZERO

func _ready():
	rotator_vec += Vector3(randfn(0, 0.5), randfn(0, 0.5), randfn(0, 0.5))

func _process(delta):
	rotation += delta * rotator_vec
