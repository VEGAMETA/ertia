class_name Spawner extends MultiplayerSpawner

var player_scene_path : String = "uid://diyb5sbluyv0b"
var player_scene : PackedScene = load(player_scene_path)

func _ready() -> void:
	add_to_group("Spawner")
	add_spawnable_scene(player_scene_path)
	set_spawn_function(spawn_player)
	spawned.connect(on_spawned)
	#despawned.connect(on_despawned)
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(peer_id: int) -> void:
	#await get_tree().create_timer(1).timeout
	spawn(peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	Utils.kill(peer_id)

#
#func on_despawned(spawned_node: Node) -> void:
	#spawned_node.queue_free()


func on_spawned(spawned_node: Node) -> void:
	if not spawned_node.is_in_group("Player"):
		spawned_node.queue_free()
	
	#player.global_position = global_position
	#player.global_position.y += 1.5


func check_players(peer_id:int) -> bool:
	return Utils.get_player_by_id(peer_id) != null


func spawn_player(peer_id:int=1) -> Node:
	if check_players(peer_id): return Node.new()
	if not player_scene.can_instantiate(): 
		Console .printerr("Cannot instantiate!")
		return Node.new()
	var player : Player = player_scene.instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	player.set_global_rotation.call_deferred(get_node(spawn_path).global_rotation)
	player.set_global_position.call_deferred(
		get_node(spawn_path).global_position + Vector3(0, 1.5, 0)
	)
	return player
