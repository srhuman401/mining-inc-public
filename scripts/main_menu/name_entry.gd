class_name NameEntryPrompt
extends Control

@export var name_input: LineEdit
@export var confirm: Button
@export var cancel: Button

var prompt_awaiting: bool = false

class Result:
	var success: bool = false
	var enter_name: String = ""
	static func n(s: bool, nm: String = "") -> Result: 
		var instance = Result.new()
		instance.enter_name = nm
		instance.success = s
		return instance

signal prompt_submitted(Result)

func _ready() -> void:
	confirm.pressed.connect(_on_confirm_pressed)
	cancel.pressed.connect(_on_cancel_pressed)

func _on_confirm_pressed():
	var entered: String = name_input.text
	if entered.strip_edges().is_empty():
		return
	prompt_awaiting = false
	visible = false
	prompt_submitted.emit(Result.n(true, entered))

func _on_cancel_pressed():
	prompt_awaiting = false
	visible = false
	prompt_submitted.emit(Result.n(false))

func prompt() -> void:
	prompt_awaiting = true
	visible = true
