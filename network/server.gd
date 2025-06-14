class_name Server extends NetworkHost

var clients : Dictionary = {}

enum Permission { NONE, DEFAULT, ADMIN, CUSTOM }


func serve() -> Error:
	result = peer.create_server(port, MAX_CLIENTS)
	if result: return result
	multiplayer.multiplayer_peer = peer
	#multiplayer.peer_connected.connect(_on_connect)
	#multiplayer.peer_disconnected.connect(_on_disconnect)
	return OK


func status() -> String:
	match peer.get_connection_status():
		MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTED: return "serving"
		MultiplayerPeer.ConnectionStatus.CONNECTION_DISCONNECTED: return "disconnected"
		MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTING: return "initializating..."
	printerr("Unreachable")
	return "Unreachable"


func _on_connect(peer_id:int) -> void:
	clients[peer_id] = Permission.DEFAULT
	print("serv conn")


func set_permission(peer_id:int, permission:Permission) -> void:
	clients[peer_id] = permission


func _on_disconnect(peer_id:int) -> void:
	clients.erase(peer_id)
	print("serv disc")
