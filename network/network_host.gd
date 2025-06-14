class_name NetworkHost extends Node

const MAX_RECONNECTIONS : int = 5
const MAX_CLIENTS : int = 16

@export var ip : String = "127.0.0.1"
@export var port : int = 2423

var peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var result : Error
