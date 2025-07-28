class_name Server extends NetworkHost

enum Permission { NONE, DEFAULT, ADMIN, CUSTOM }

@export var MAX_CLIENTS : int = 16
@export var PORT : int = 2423

var clients : Dictionary = {}
var map : String = ""

signal player_loaded_map(peer_id:int)


func _ready() -> void:
	multiplayer.allow_object_decoding = true
	multiplayer.peer_connected.connect(_on_connect)
	multiplayer.peer_disconnected.connect(_on_disconnect)
	var maps : PackedStringArray = Utils.get_maps()
	if not maps: return


func _on_connect(peer_id:int) -> void:
	clients[peer_id] = Permission.DEFAULT
	Console.print("Client %d connected" % peer_id)
	if multiplayer.is_server():
		#Utils.load_map.rpc_id.call_deferred(peer_id, map)
		Globals.client.client_change_map.rpc_id(peer_id, Utils.get_full_map_name(map))

func _on_disconnect(peer_id:int) -> void:
	clients.erase(peer_id)
	Console.print("Client %d disconnected" % peer_id)


func serve() -> Error:
	Console.print("Serving...")
	result = peer.create_server(PORT, MAX_CLIENTS)
	if result: return Console.printerr("Couldn't serve the server!", result)
	multiplayer.multiplayer_peer = peer
	return OK


func status() -> String:
	match peer.get_connection_status():
		MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTED: return "serving"
		MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTING: return "initializating..."
		MultiplayerPeer.ConnectionStatus.CONNECTION_DISCONNECTED: return "disconnected"
		_: Console.printerr("Unreachable - Server")
	return "Unreachable"


func set_permission(peer_id:int, permission:Permission) -> void:
	clients[peer_id] = permission


@rpc("authority", "call_local")
func set_scene() -> void:
	Globals.client.client_change_map.rpc(Utils.load_map(map))


@rpc("authority", "call_remote")
func change_client_map(_peer_id:int) -> void:
	if not map or map == "": return
	#Globals.client.client_change_map.rpc_id(peer_id, Utils.get_full_map_name(map))


func get_map() -> String:
	return map


@rpc("any_peer", "call_local")
func spawn_player(peer_id:int) -> void:
	if not multiplayer.is_server(): return
	if get_tree().current_scene == null: return Console.printerr("Cannot spawn - no map")
	var spawner := get_tree().get_first_node_in_group("Spawner") as Spawner
	if spawner == null: return Console.printerr("Cannot spawn - nowhere to spawn")
	var spawned : Node = spawner.spawn(peer_id)
	if spawned == null: return Console.printerr("Cannot spawn - wrong authority")

@rpc("any_peer", "call_remote")
func loaded_map() -> void:
	player_loaded_map.emit()
