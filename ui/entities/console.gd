extends Control

@onready var command_output : RichTextLabel = %CommandOutput
@onready var command_line : LineEdit = %CommandLine

var suggestions : Array[String] = []
var suggesting : bool = false

var buff_text : String = ""

func _ready() -> void:
	Console.stream_updated.connect(set_text)
	command_line.text_submitted.connect(submit_command)
	command_line.edit.call_deferred()
	command_line.text_changed.connect(_inspect_text)


func _notification(what) -> void:
	match what:
		NOTIFICATION_VISIBILITY_CHANGED:
			if not command_line: return
			if visible: command_line.edit.call_deferred()
			else: command_line.unedit()

func _input(event) -> void:
	if event.is_action_pressed("ui_focus_next"):
		get_suggestions()
		

func get_suggestions() -> void:
	if not suggestions:
		var text = command_line.text.strip_edges()
		if buff_text:
			text = buff_text
			buff_text = ""
		if text.length() < 1: return
		suggestions = CommandHandler.avalible_commands.filter(func (x:String): return x.begins_with(text))
		buff_text = text
	if not suggestions: return
	command_line.text = suggestions.pop_at(0)
	command_line.caret_column = command_line.text.length()
	suggesting = true


func _inspect_text(new_text: String) -> void:
	if suggesting:
		buff_text = ""
		suggesting = false
		suggestions = []


func submit_command(text) -> void:
	CommandHandler.handle_command(text)
	command_line.clear.call_deferred()
	command_line.edit.call_deferred()


func set_text() -> void:
	command_output.text = Console.stream
