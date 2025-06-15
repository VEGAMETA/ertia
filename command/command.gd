class_name Command extends Node

var result : Error = OK

var command : PackedStringArray

static func get_registered() -> Array[String]:
	return []

func _init(_command:PackedStringArray) -> void:
	command = _command

func execute() -> Error:
	return OK

func _error() -> void: return printerr("cannot operate")
