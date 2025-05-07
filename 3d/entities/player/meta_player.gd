class_name APlayer
extends Abstract

var states = preload("res://3d/entities/player/states_player.tres").state_list

var fsm = FSM.new(states)
