extends VBoxContainer

@onready var focus_sfx : AudioStreamPlayer = %FocusSFX

var first_focus : bool = true


func _on_button_mouse_entered(source:Control) -> void:
	if not source.has_focus():
		source.grab_focus()


func _on_button_focused() -> void:
	if first_focus: 
		first_focus = false
		return
	if !owner.visible: return
	focus_sfx.set_pitch_scale(randf_range(2.5, 2.6))
	focus_sfx.play()
	


func _on_button_pressed() -> void:
	focus_sfx.set_pitch_scale(randf_range(2.0, 2.1))
	focus_sfx.play()
