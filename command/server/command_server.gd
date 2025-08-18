class_name CommandServer extends Command 

var server : Server = Globals.server
var help_message : String = \
"""Command: server - show main info about server

help - shows this message
serve - serves the server with setted parameters
map - changes server map
spawn - spawns server authority

clients - shows clients
status - server status
port new_port - shows/sets server port (1025-65535)
set_permission peer_id permission - sets permission for client
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
		"set_permission":
			if command.size() > 3:
				var peer_id: int = int(command[2])
				var permission: int = int(command[3])
				if permission not in Server.Permission.values():
					return Console.printerr("incorrect Permission %d" % permission, ERR_INVALID_PARAMETER)
				server.set_permission(peer_id, permission)
	return OK
