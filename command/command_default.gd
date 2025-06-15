class_name CommandDefault extends Command

var help_message : String = \
"""This is console 
help - show this message
clear/cls/clr - clear console
connect ip port - connect to server with given ip (IPv4) and port (1025-65535) 
server - handle server
exit/quit - quit game
map - load map
maps - show maps
pause - pauses the game
unpause - pauses the game
"""


static func get_registered() -> Array[String]:
	return [
		"help", 
		"clear", "clr", "cls", 
		"exit", "quit", 
		"connect",
		"map", "maps",
		"pause", "unpause"
	]


func execute() -> Error: 
	match command[0]:
		"help": Console.print(help_message)
		"clear": Console.clear()
		"clr": Console.clear()
		"cls": Console.clear()
		"exit": Globals.quit()
		"quit": Globals.quit()
		"maps": Console.print("%s" % Utils.get_maps())
		"map": if command.size() > 1: Utils.load_map(command[1])
		"pause": Globals.get_tree().paused = true
		"unpause": Globals.get_tree().paused = false
		"connect": if command.size() > 2:
			var ip : String = Utils.validate_ip(command[2])
			if not ip: return Console.printerr("incorrect ip", ERR_CANT_RESOLVE)
			var port : int = int(command[3])
			port = port if port > 1024 and port < 65536 else 0
			if not port: return Console.printerr("incorrect port", ERR_CANT_RESOLVE)
			Console.print("connecting to {}".format([ip], "{}"))
	return OK
