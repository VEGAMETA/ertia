class_name SpawnPoint3D extends Marker3D

@export_node_path("Node")
var spawn_path_node : NodePath

var player_scene_path : String = "uid://diyb5sbluyv0b"
var player_scene : PackedScene = load(player_scene_path)

@onready var spawner : MultiplayerSpawner = %MultiplayerSpawner


func _ready() -> void:
	add_to_group("SpawnPoint")
	spawn_path_node = NodePath(spawn_path_node.get_concatenated_names().insert(0, "../"))
	spawner.set_spawn_path(spawn_path_node if spawn_path_node != null else get_parent().get_path())
	print(spawner.spawn_path)
	spawner.set_spawn_function(spawn_player)
	spawner.spawned.connect(_on_spawned)
	spawner.despawned.connect(_on_despawned)
	Globals.server.multiplayer.peer_connected.connect(spawner.spawn)
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(peer_id: int) -> void:
	var player : BasePlayer = spawner.spawn(peer_id)
	if player == null: return
	await get_tree().process_frame
	spawner.add_spawnable_scene(String(player.get_path()))

func _on_peer_disconnected(peer_id: int) -> void:
	Utils.kill(peer_id)


func _on_despawned(spawned: Node) -> void:
	spawned.queue_free()


func _on_spawned(spawned: Node) -> void:
	spawned.reparent(get_tree().current_scene)
	#player.global_position = global_position
	#player.global_position.y += 1.5


func check_players(peer_id:int) -> bool:
	return Utils.get_player_by_id(peer_id) != null


func spawn_player(peer_id:int=1) -> Node:
	if check_players(peer_id): return null
	if not player_scene.can_instantiate(): 
		Console.printerr("Cannot instantiate!")
		return null
	var player : Player = player_scene.instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	player.set_global_rotation.call_deferred(global_rotation)
	player.set_global_position.call_deferred(
		global_position + Vector3(0, 1.5, 0)
	)
	return player
