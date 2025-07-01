class_name SpawnPoint3D extends Marker3D

var player_scene_path = "uid://diyb5sbluyv0b"
var player_scene : PackedScene = load(player_scene_path)
var player : Player


@onready var spawner : MultiplayerSpawner = %MultiplayerSpawner

func _ready() -> void:
	add_to_group("SpawnPoint")
	#spawner.add_spawnable_scene(player_scene_path)
	spawner.spawn_function = spawn_player
	spawner.spawned.connect(_on_spawned)
	spawner.despawned.connect(_on_despawned)
	Globals.server.multiplayer.peer_connected.connect(spawner.spawn)


func _on_despawned(spawned: Node) -> void:
	spawned.queue_free()


func _on_spawned(spawned: Node) -> void:
	spawned.reparent(get_tree().current_scene)
	#player.global_position = global_position
	#player.global_position.y += 1.5


func spawn_player(peer_id:int=1) -> Node:
	if not player_scene.can_instantiate(): 
		Console.printerr("Cannot instantiate!")
		return null
	player = player_scene.instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	player.set_global_rotation.call_deferred(global_rotation)
	player.set_global_position.call_deferred(
		global_position + Vector3(0, 1.5, 0)
	)
	return player
