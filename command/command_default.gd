class_name CommandDefault extends Command

var help_message : String = \
"""This is console 
help - show this message
clear/cls/clr - clear console
connect ip port - connect to server with given ip (IPv4) and port (1000-65535) 
server - handle server
exit/quit - quit game

"""

static func get_registered() -> Array[String]:
	return [
		"help", 
		"clear", "clr", "cls", 
		"exit", "quit", 
		"connect", 
	]


func execute() -> Error:
	match command[0]:
		"help": Console.print(help_message)
		"clear": Console.clear()
		"clr": Console.clear()
		"cls": Console.clear()
		"exit": Globals.quit()
		"quit": Globals.quit()
		"connect":
			if command.size() > 2:
				var ip : String = Utils.validate_ip(command[2])
				if not ip: Console.printerr("incorrect ip"); return ERR_CANT_RESOLVE
				var port : int = int(command[3])
				port = port if port > 1000 and port < 65536 else 0
				if not port: Console.printerr("incorrect port"); return ERR_CANT_RESOLVE
				Console.print("connecting to {}".format([ip], "{}"))
	return OK
