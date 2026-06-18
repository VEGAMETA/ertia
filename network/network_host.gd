class_name NetworkHost extends Node

var peer := ENetMultiplayerPeer.new()
var result := OK

func connected() -> bool:
	return peer.get_connection_status() == MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTED
