class_name Client extends NetworkHost

@export var MAX_RECONNECTIONS : int = 3
var counter : int = MAX_RECONNECTIONS

var default_ip : String = "localhost"
var default_port : int = 2423
var connecting_server : Dictionary = {"ip" = null, "port" = null}


func _ready() -> void:
	multiplayer.allow_object_decoding = true
	multiplayer.connected_to_server.connect(_on_connect)
	multiplayer.server_disconnected.connect(_on_disconnect)
	multiplayer.connection_failed.connect(_on_connection_failed)

func _on_connection_failed() -> void:
	Console.printerr("Couldn't connect to %s:%s" % connecting_server.values(), ERR_CANT_CONNECT)
	connecting_server.set("ip", null)
	connecting_server.set("port", null)


func _reconnect() -> Error:
	#if counter < 1: 
		#counter = MAX_RECONNECTIONS
		#connecting_server.set("ip", null)
		#connecting_server.set("port", null)
		#return ERR_CANT_CONNECT
	#counter -= 1
	return await connect_to_server(
		connecting_server.get("ip"),
		connecting_server.get("port"),
	)


func _on_connect() -> void:
	Console.print("\nConnected to server %s" % connecting_server.get("ip"))


func _on_disconnect() -> void:
	Console.print("\nDisconnected from server %s" % connecting_server.get("ip"))
	connecting_server.set("ip", null)
	connecting_server.set("port", null)
	Menu.menu()


func status() -> String:
	match peer.get_connection_status():
		MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTED: return "connected to " % % connecting_server.get("ip")
		MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTING: return "connecting to..." % connecting_server.get("ip")
		MultiplayerPeer.ConnectionStatus.CONNECTION_DISCONNECTED: return "disconnected"
		_: Console.printerr("Unreachable - Client")
	return "Unreachable"


func connect_to_server(ip:String, port:int) -> Error:
	disconnect_from_server()
	peer.close()
	multiplayer.set_multiplayer_peer(null)
	await get_tree().process_frame
	Console.print("Connecting to %s:%d" % [ip, port])
	connecting_server.set("ip", ip)
	connecting_server.set("port", port)
	result = peer.create_client(ip, port)
	if result:
		Console.printerr("Couldn't connect to %s" %ip, result)
		return result
	multiplayer.multiplayer_peer = peer
	return OK


func disconnect_from_server() -> void:
	if peer.get_connection_status() != MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTED: return
	var server_peer : ENetPacketPeer = peer.get_peer(get_multiplayer_authority())
	if not server_peer: return Console.printerr("Cannot get server instance", ERR_CONNECTION_ERROR) 
	server_peer.peer_disconnect_now.call_deferred()

func request_spawn() -> void:
	Globals.server.spawn_player.rpc_id(get_multiplayer_authority(), multiplayer.get_unique_id())


@rpc("any_peer", "call_remote", "unreliable_ordered")
func client_change_scene(scene: PackedScene) -> void:
	print(get_tree().change_scene_to_packed(scene))


@rpc("authority", "call_remote", "reliable")
func client_change_map(path: String) -> void:
	if get_tree().current_scene != null:
		if path == get_tree().current_scene.scene_file_path:
			return
	#if multiplayer.is_server(): return
	var new_scene := (load(path) as PackedScene).instantiate()
	var current_scene := get_tree().current_scene
	if get_tree().current_scene != null:
		get_tree().root.remove_child(current_scene)
		current_scene.queue_free()
	get_tree().root.add_child.call_deferred(new_scene)
	get_tree().set_current_scene.call_deferred(new_scene)
	await new_scene.ready
	_reconnect()
