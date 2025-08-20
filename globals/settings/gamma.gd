extends ColorRect

var gamma_shader : Shader = preload("uid://b1jxkk2hhmpgo")
var shader_material := ShaderMaterial.new()

func _ready() -> void:
	shader_material.shader = gamma_shader
	material = shader_material
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	set_gamma(Settings.gamma)

func get_gamma() -> float:
	return shader_material.get_shader_parameter(&"gamma")

func set_gamma(value:float) -> void:
	shader_material.set_shader_parameter(&"gamma", value)
