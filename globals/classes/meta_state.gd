class_name AState
extends Abstract

@export_category("State")
@export_custom(PROPERTY_HINT_TYPE_STRING, "Name") var name : StringName
@export_custom(PROPERTY_HINT_NONE, "Value") var value : Variant

func _init(_name:StringName, _value:Variant) -> void:
	self.name = _name
	self.value = _value
