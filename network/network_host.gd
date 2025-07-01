class_name NetworkHost extends Node

var peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var result : Error = OK

func connected() -> bool:
	return peer.get_connection_status() == MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTED
