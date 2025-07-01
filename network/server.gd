class_name Server extends NetworkHost

enum Permission { NONE, DEFAULT, ADMIN, CUSTOM }

@export var MAX_CLIENTS : int = 16
@export var PORT : int = 2423

var clients : Dictionary = {}
var map : String = ""


func _ready() -> void:
	multiplayer.allow_object_decoding = true
	multiplayer.peer_connected.connect(_on_connect)
	multiplayer.peer_disconnected.connect(_on_disconnect)
	var maps : PackedStringArray = Utils.get_maps()
	if not maps: return
	map = maps[0]


func _on_connect(peer_id:int) -> void:
	clients[peer_id] = Permission.DEFAULT
	Console.print("Client %d connected" % peer_id)
	change_client_map(peer_id)


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


func set_scene() -> void:
	Globals.client.client_change_map.rpc(Utils.load_map(map))
	await get_tree().process_frame
	Globals.client.request_spawn.rpc.call_deferred()
	#spawn_player.call_deferred(multiplayer.get_unique_id())


@rpc("any_peer", "call_local", "unreliable_ordered")
func change_client_map(peer_id:int) -> void:
	if not map or map == "": return
	Globals.client.client_change_map.rpc_id(peer_id, Utils.get_full_map_name(map))
	#var packed := PackedScene.new()
	#packed.pack(get_tree().current_scene)
	#Globals.client.client_change_scene.rpc_id(peer_id, packed)


func get_map() -> String:
	return map


@rpc("any_peer", "call_local", "reliable")
func spawn_player(peer_id:int) -> void:
	if get_tree().current_scene == null: return Console.printerr("Cannot spawn - no map")
	var spawn_point := get_tree().get_first_node_in_group("SpawnPoint") as SpawnPoint3D
	if spawn_point == null: return Console.printerr("Cannot spawn - nowhere to spawn")
	var spawned : Node = spawn_point.spawner.spawn(peer_id)
	spawned.reparent(get_tree().current_scene)
	if spawned == null: return Console.printerr("Cannot spawn - wrong authority")
