extends MeshInstance3D


func _ready() -> void:
	Menu.menu_toggle.connect(menu_called)

## Getting rid of menue's blur flashes when resizing
func menu_called(toggled: bool) -> void:
	if toggled: return
	set_visible(false)
	await get_tree().process_frame
	await get_tree().process_frame
	set_visible(true)
