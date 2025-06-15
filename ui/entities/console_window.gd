class_name ConsoleWindow extends Window

var buff_text : String = ""
var suggesting : bool = false
var suggestions : Array[String] = []

var buff_history : String = ""
var historing : bool = false
var history_count : int = -1

@onready var command_output : RichTextLabel = %CommandOutput
@onready var command_line : LineEdit = %CommandLine


func _ready() -> void:
	close_requested.connect(close)
	Console.stream_updated.connect(set_text)
	set_text()
	command_line.text_submitted.connect(submit_command)
	command_line.edit.call_deferred()
	command_line.text_changed.connect(_inspect_text)


func _notification(what) -> void:
	match what:
		NOTIFICATION_VISIBILITY_CHANGED:
			if not command_line: return
			if visible: command_line.edit.call_deferred()
			else: command_line.unedit.call_deferred()
		NOTIFICATION_WM_MOUSE_ENTER:
			if visible: command_line.edit.call_deferred()
			else: command_line.unedit.call_deferred()

func _input(event) -> void:
	if not visible: return
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("debug_console"):
		visible = false
	if event.is_action_pressed("ui_focus_next"):
		get_suggestions()
	if event.is_action_pressed("ui_up"):
		get_history(true)
	if event.is_action_pressed("ui_down"):
		get_history(false)


func close() -> void:
	visible = false


func submit_command(text) -> void:
	Globals.command_handler.handle_command(text)
	command_line.clear.call_deferred()
	command_line.edit.call_deferred()
	clear_history()
	clear_suggests()


func set_text() -> void:
	command_output.text = Console.stream


func get_suggestions() -> void:
	suggesting = true
	if not suggestions:
		var text = command_line.text.strip_edges()
		if buff_text:
			text = buff_text
			buff_text = ""
		if text.length() < 1: return
		suggestions = Globals \
		.command_handler \
		.avalible_commands \
		.filter(
			func (x:String): 
				return x.begins_with(text)
		)
		buff_text = text
	if not suggestions: return
	command_line.text = suggestions.pop_at(0)
	command_line.caret_column = command_line.text.length()


func clear_suggests() -> void:
	buff_text = ""
	suggesting = false
	suggestions = []


func get_history(history_direction:bool) -> void:
	history_count += 1 if history_direction else -1
	if history_count >= Console.command_history.size(): history_count -= 1
	if history_count < -1: history_count += 1
	if not buff_history: buff_history = command_line.text
	if not buff_history: buff_history += " "
	if history_count < 0:
		command_line.text = buff_history.strip_edges()
		return
	command_line.text = Console.command_history[history_count]
	command_line.set_caret_column.call_deferred(command_line.text.length())
	historing = true


func clear_history() -> void:
	buff_history = ""
	historing = false
	history_count = -1


func _inspect_text(_new_text: String) -> void:
	if historing: clear_history()
	if suggesting: clear_suggests()
