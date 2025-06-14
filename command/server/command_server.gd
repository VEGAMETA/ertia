class_name CommandServer extends Command 

var server : Server = Globals.server

var help_message : String = \
"""Command: server - show main info about server

help - shows this message
serve - serves the server with setted parameters

get_clients - shows clients

set_port port - sets server port (1000-65535)
set_ip ip - sets server ip in IPv4 format (e.g. 192.168.0.255 (0-255))
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
	result = OK
	match command.size():
		1:
			match command[0]:
				"server":
					Console.print(
						"server help - show commands\nport - %d\nip - %s\nclients - %s\n" % [
						server.port, server.ip, server.clients
					])
		2:
			match command[1]:
				"help": Console.print(help_message)
				"serve": result = server.serve()
				"get_clients": Console.print("%s" % server.clients)
				"status": Console.print(server.status())
				"port": Console.print("%d" % server.port)
				"ip": Console.print("%s" % server.ip)
		3:
			match command[1]:
				"port":
					var port : int = int(command[2])
					port = port if port > 1000 and port < 65536 else 0
					if port: server.port = port
					else: result = ERR_CANT_RESOLVE; Console.printerr("incorrect port")
				"ip":
					var ip : String = Utils.validate_ip(command[2])
					if ip: server.ip = ip
					else: result = ERR_CANT_RESOLVE; Console.printerr("incorrect ip")
	return result
