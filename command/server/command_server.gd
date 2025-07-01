class_name CommandServer extends Command 

var server : Server = Globals.server
var help_message : String = \
"""Command: server - show main info about server

help - shows this message
serve - serves the server with setted parameters

clients - shows clients

port (new port) - shows/sets server port (1025-65535)
set_permission ip permission - sets permission for client
Permissions: 
	0 - NONE; 
	1 - DEFAULT; 
	2 - ADMIN; 
	3 - CUSTOM
"""


static func get_registered() -> Array[String]:
	return ["server",]


func execute() -> Error:
	if command.size() < 2:
		Console.print(
			"server help - show commands\nport - %d\nclients - %s\n" % [
			server.PORT, server.clients
		])
		return OK
	match command[1]:
		"help": Console.print(help_message)
		"serve": return server.serve()
		"clients": Console.print("%s" % server.clients)
		"status": Console.print(server.status())
		"spawn": server.spawn_player(1)
		"map":
			if command.size() > 2:
				var map : String = command[2] 
				if map not in Utils.get_maps(): return ERR_INVALID_PARAMETER
				server.map = map
				server.set_scene()
			Console.print("%s" % server.map)
		"port": 
			if command.size() > 2:
				var port : int = int(command[2])
				port = port if port > 1024 and port < 65536 else 0
				if port: server.PORT = port
				else: return Console.printerr("incorrect port", ERR_CANT_RESOLVE)
			Console.print("port - %d" % server.PORT)
	return OK
