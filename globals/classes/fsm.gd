class_name FSM
extends Object

@export var states : Dictionary = {}

signal state_changed

@export_custom(PROPERTY_HINT_ARRAY_TYPE, "Allowed States") 
var state_list : Array[AState]

func _init(_state_list:Array[AState]=[]) -> void:
	state_list = _state_list

func check_state(state: AState) -> bool: 
	return state in states

func get_states() -> Array[AState]:
	return states.keys()

func get_state_by_name(name: StringName) -> AState:
	return states.find_key(name)

func add_state(state: AState) -> void: 
	if not state in state_list and not state_list.is_empty(): 
		return push_error("State isn't allowed")
	states.get_or_add(state, state.name)
	state_changed.emit(state)

func pop_state(state: AState) -> void:
	states.erase(state)
	state_changed.emit(state)
