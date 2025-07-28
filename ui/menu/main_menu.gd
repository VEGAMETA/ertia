class_name MainMenu extends Control

var shown := false

@onready var blur_rect : ColorRect = %Blur

@onready var serve_button : Button = %Serve
@onready var connect_button : Button = %Connect
@onready var disconnect_button : Button = %Disconnect
@onready var quit_button : Button = %Quit
@onready var play_button : Button = %Play
@onready var options_button : Button = %Options

@onready var ip_field : LineEdit = %Ip
@onready var port_field : LineEdit = %Port
@onready var transition: TextureRect = $Transition

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	quit_button.pressed.connect(Globals.quit)
	serve_button.pressed.connect(Globals.server.serve)
	connect_button.pressed.connect(_on_connect_pressed)
	disconnect_button.pressed.connect(Globals.client.disconnect_from_server)
	play_button.pressed.connect(Utils.load_map.bind("test"))
	animation_player.animation_finished.connect(animation_played)
	if get_tree().current_scene != self:
		animation_player.play(&"transition")
		animation_player.animation_finished.disconnect(animation_played)
	


func animation_played(anim:StringName) -> void:
	if !visible: return
	visible = false


func toggle() -> bool:
	animation_player.pause()
	if visible:
		animation_player.play(&"transition", -1, -2.5, true)
		animation_player.animation_finished.connect(animation_played)
		return false
	else:
		visible = true
		animation_player.play(&"transition")
		if animation_player.animation_finished.is_connected(animation_played):
			animation_player.animation_finished.disconnect(animation_played)
		return true


func _on_connect_pressed() -> void:
	await Globals.client.connect_to_server(
		ip_field.text if ip_field.text != "" else \
		Globals.client.default_ip,
		int(port_field.text) if port_field.text != "" else \
		Globals.client.default_port,
	)

func blur(enable:bool=true) -> void:
	blur_rect.set_visible(enable)
