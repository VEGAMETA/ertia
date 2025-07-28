class_name CommandDefault extends Command

var help_message : String = \
"""This is console 
help - show this message
clear/cls/clr - clear console
connect ip port - connect to server with given ip (IPv4) and port (1025-65535) 
server - handle server
exit/quit - quit game
close - toggle console
map - load map
maps - show maps
pause - pauses the game
unpause - pauses the game
toggle_fullscreen - toggles fullscreen window mode
"""


static func get_registered() -> Array[String]:
	return [
		"help", 
		"clear", "clr", "cls", 
		"exit", "quit",
		"close",
		"connect", "disconnect",
		"map", "maps",
		"toggle_pause",
		"toggle_fullscreen",
		"spawn", "kill",
	]


func execute() -> Error: 
	match command[0]:
		"help": Console.print(help_message)
		"clear": Console.clear()
		"clr": Console.clear()
		"cls": Console.clear()
		"exit": Globals.quit()
		"quit": Globals.quit()
		"close": Console.toggle_console()
		"maps": Console.print("%s" % "\n".join(Utils.get_maps()))
		"map": 
			if command.size() > 1: Utils.load_map(command[1])
			elif Globals.get_tree(): Console.print(Globals.get_tree().current_scene.name)
		"toggle_pause": Globals.toggle_pause()
		"toggle_fullscreen": Globals.toggle_fullscreen()
		"spawn": Globals.client.request_spawn()
		"kill": 
			Utils.kill()
			Utils.kill.rpc(Globals.multiplayer.get_unique_id())
		"disconnect": Globals.client.disconnect_from_server()
		"connect": if command.size() > 2:
			var ip : String = Utils.validate_ip(command[1])
			if not ip: return Console.printerr("incorrect ip", ERR_CANT_RESOLVE)
			var port : int = int(command[2])
			port = port if port > 1024 and port < 65536 else 0
			if not port: return Console.printerr("incorrect port", ERR_CANT_RESOLVE)
			await Globals.client.connect_to_server(ip, port)

	return OK
