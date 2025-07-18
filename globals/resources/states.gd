class_name States 
extends Resource

@export_custom(PROPERTY_HINT_DICTIONARY_TYPE, "States") var states : Dictionary

var state_list : Array[AState]

func _init() -> void:
	states.keys().map(
		func (key:String) -> void: 
			state_list.append(AState.new(key, states.get(key)))
	)
