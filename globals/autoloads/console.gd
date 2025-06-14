extends Node

var shown = false
var command_history : Array[PackedStringArray] = []
var stream : String : 
	set(v): 
		stream = v
		stream_updated.emit()

signal stream_updated


func clear() -> void:
	stream = ""


func print(text:String) -> void:
	stream += text


func printerr(text:String) -> void:
	stream += "[color=red]%s[/color]\n" % text
