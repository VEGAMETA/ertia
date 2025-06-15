class_name CommandHandler extends Node
 
var avalible_commands : Array[String] = []
var command_queue : Array[PackedStringArray] = []
var commander_classes : Array[GDScript] = []
var command : PackedStringArray
var executor : Command


func _ready():
	var commanders = Utils.get_subclasses("Command")
	for commander in commanders:
		var commander_class = Utils.get_class_from_string(commander)
		commander_classes.append(commander_class)
		avalible_commands += commander_class.get_registered()


func execute(_command:PackedStringArray) -> void:
	if not _command: return
	var joined_command : String = " ".join(_command)
	Console.print("\n> " + joined_command + "\n")
	if not joined_command: return
	find_command(_command)
	if not executor.execute():
		Console.command_history.push_front(joined_command)


func find_command(_command) -> void:
	var command_class = Command
	for commander_class in commander_classes:
		if _command[0] not in commander_class.get_registered(): continue
		command_class = commander_class
	executor = command_class.new(_command)


func execute_queue() -> void:
	if not command_queue: return
	execute(command_queue.pop_at(0))


func handle_command(text:String) -> void:
	command = text.strip_edges().strip_escapes().split(" ")
	command_queue.append(command.duplicate())
	execute_queue.call_deferred()
