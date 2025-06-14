class_name Client extends NetworkHost

var connected_server : Server


func _init() -> void:
	port += 1


func status() -> String:
	match peer.get_connection_status():
		MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTED: return "connected to "
		MultiplayerPeer.ConnectionStatus.CONNECTION_DISCONNECTED: return "disconnected"
		MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTING: return "connecting..."
	printerr("Unreachable")
	return "Unreachable"


func connect_to_server(server:Server) -> Error:
	result = peer.create_client(server.ip, server.port)
	if result: return result
	#multiplayer.multiplayer_peer = peer
	#multiplayer.connected_to_server.connect(_on_connect)
	#multiplayer.server_disconnected.connect(_on_disconnect)
	#multiplayer.connection_failed.connect(_reconnect)
	return OK


func _reconnect() -> Error:
	var counter : int = MAX_RECONNECTIONS
	var timer : Timer = Timer.new()
	while counter:
		counter -= 1
		timer.start()
		await timer.timeout
		result = connect_to_server(connected_server)
		if result: continue
		else: break
	return result


func _on_connect() -> void:
	print_debug("cli conn")


func _on_disconnect() -> void:
	print_debug("cli disc")
