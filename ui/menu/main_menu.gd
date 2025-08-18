class_name MainMenu extends Control

var shown := false


var settings_packed : PackedScene = preload("uid://cu0e75nu504kb")
var settings : SettingsWindow

@onready var blur_rect : ColorRect = %Blur

@onready var serve_button : Button = %Serve
@onready var connect_button : Button = %Connect
@onready var disconnect_button : Button = %Disconnect
@onready var quit_button : Button = %Quit
@onready var continue_button : Button = %Continue
@onready var new_game_button : Button = %NewGame
@onready var options_button : Button = %Options

@onready var ip_field : LineEdit = %Ip
@onready var port_field : LineEdit = %Port
@onready var transition: TextureRect = $Transition

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var background : ColorRect = $Background
@onready var camera : Camera3D = %Camera3D
@onready var hand : Node3D = %Hand
@onready var shadow: TextureRect = $Shadow
@onready var network: VBoxContainer = $Menu/Network

func _ready() -> void:
	quit_button.pressed.connect(Globals.quit)
	options_button.pressed.connect(open_settings)
	serve_button.pressed.connect(Globals.server.serve)
	connect_button.pressed.connect(_on_connect_pressed)
	disconnect_button.pressed.connect(Globals.client.disconnect_from_server)
	new_game_button.pressed.connect(Utils.load_map.bind("test"))
	network.visible = Globals.network
	Menu.network_toggle.connect(func (v:bool) -> void: network.visible = v)
	if get_tree().current_scene != self:
		animation_player.play(&"transition")
		continue_button.visible = true
		shadow.visible = true
		continue_button.pressed.connect(Menu.toggle_menu)
	else:
		transition.material.set_shader_parameter(&"progress", -5)
		if Saver.get_saves().size() > 0:
			continue_button.visible = true
			continue_button.pressed.connect(Saver.load_last_save)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_VISIBILITY_CHANGED:
			set_physics_process(visible)


func _physics_process(delta: float) -> void:
	if hand == null or camera == null: return
	hand.rotation.y += delta/33
	hand.rotation.x -= delta/20
	hand.rotation.z -= delta/15
	camera.environment.sky_rotation += Vector3(delta/41, delta/9, 0)
	

func animation_played(_anim:StringName) -> void:
	if !visible: return
	visible = false


func toggle() -> bool:
	animation_player.pause()
	if visible: # Close menu
		if settings: settings.visible = false
		animation_player.play(&"transition", -1, -2.5, true)
		if not animation_player.animation_finished.is_connected(animation_played):
			animation_player.animation_finished.connect(animation_played)
		return false
	else: # Open menu
		visible = true
		animation_player.play(&"transition")
		if animation_player.animation_finished.is_connected(animation_played):
			animation_player.animation_finished.disconnect(animation_played)
		return true


func open_settings() -> void:
	if settings:
		settings.visible = true
		return
	if settings_packed.can_instantiate():
		settings = settings_packed.instantiate()
		add_child(settings)

func _on_connect_pressed() -> void:
	await Globals.client.connect_to_server(
		ip_field.text if ip_field.text != "" else \
		Globals.client.default_ip,
		int(port_field.text) if port_field.text != "" else \
		Globals.client.default_port,
	)

func blur(enable:bool=true) -> void:
	blur_rect.set_visible(enable)
