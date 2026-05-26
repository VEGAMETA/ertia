extends MeshInstance3D


func _ready() -> void:
	Menu.menu_toggle.connect(menu_called)
	menu_called(false)

## Getting rid of menue's blur flashes when resizing
func menu_called(toggled: bool) -> void:
	if toggled: return
	set_visible(false)
	var tree := get_tree()
	if tree == null: return
	await tree.process_frame
	if tree == null: return
	await tree.process_frame
	set_visible(true)
