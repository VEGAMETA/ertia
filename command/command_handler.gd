class_name CommandHandler extends Node
 
var avalible_commands : Array[String] = []
var command_queue : Array[PackedStringArray] = []
var commander_classes : Array[GDScript] = []
var command : PackedStringArray
var executor : Command


func _ready() -> void:
	Utils.get_subclasses(Command).map(
		func (commander:String) -> void:
			var commander_class := Utils.get_class_from_string(commander)
			commander_classes.append(commander_class)
			avalible_commands += commander_class.get_registered()
	)

func execute(command_:PackedStringArray) -> void:
	if not command_: return
	var joined_command : String = " ".join(command_)
	Console.print("\n> " + joined_command + "\n")
	if not joined_command: return
	find_command(command_)
	executor.execute()
	Console.command_history.push_front(joined_command)


func find_command(command_:PackedStringArray) -> void:
	executor = commander_classes.reduce(
		func (command_class:GDScript, commander_class:GDScript) -> GDScript:
			if command_[0] in commander_class.get_registered(): 
				return commander_class
			return command_class
	, Command
	).new(command_)


func execute_queue() -> void:
	if not command_queue: return
	execute(command_queue.pop_at(0))


func handle_command(text:String) -> void:
	command = text.strip_edges().strip_escapes().split(" ")
	command_queue.append(command.duplicate())
	execute_queue.call_deferred()
