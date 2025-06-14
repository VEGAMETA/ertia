class_name CommandHandler

static var avalible_commands : Array[String] = []
static var command_queue : Array[PackedStringArray] = []
static var commander_classes : Array[GDScript] = []
static var command : PackedStringArray
static var executor : Command


static func _static_init():
	var commanders = Utils.get_subclasses("Command")
	for commander in commanders:
		var commander_class = Utils.get_class_from_string(commander)
		commander_classes.append(commander_class)
		avalible_commands += commander_class.get_registered()


static func execute(_command:PackedStringArray) -> void:
	if not _command: return
	Console.print("\n> " +" ".join(_command) + "\n")
	find_command(_command)
	if not executor.execute():
		Console.command_history.append(_command)


static func find_command(_command) -> void:
	var command_class = Command
	for commander_class in commander_classes:
		if _command[0] not in commander_class.get_registered(): continue
		command_class = commander_class
	executor = command_class.new(_command)


static func execute_queue() -> void:
	if not command_queue: return
	execute(command_queue.pop_at(0))


static func handle_command(text:String) -> void:
	command = text.strip_edges().strip_escapes().split(" ")
	command_queue.append(command.duplicate())
	execute_queue.call_deferred()
