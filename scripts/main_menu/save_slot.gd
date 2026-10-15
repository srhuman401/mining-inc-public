class_name SaveSlotUI extends Control

@export var data_yes: Control
@export var data_no: Control
@export var new_game_button: Button
@export var play_button: Button
@export var delete_button: Button
@export var slot_label: Label
@export var meta_label: Label
@export var slot: int = 1
@export var holder_screen: LoadGameScreen 

func _on_load_game_pressed():
	holder_screen.load_slot(slot)

func _on_delete_game_pressed():
	holder_screen.delete_slot(slot)

func _on_create_slot_pressed():
	holder_screen.create_slot(slot)

func refresh():
	var slot_exists := Game.slot_content_exists(slot)
	if slot_exists:
		var slot_meta := Game.retrieve_slot_meta(slot)
		data_yes.visible = true
		data_no.visible = false
		slot_label.text = "[" + str(slot) + "] " + slot_meta.company_name_string + " Co."
		meta_label.text = "COMPANY LEVEL " + str(slot_meta.company_level_integer)
	else:
		data_yes.visible = false
		data_no.visible = true

func _ready():
	new_game_button.pressed.connect(_on_create_slot_pressed)
	play_button.pressed.connect(_on_load_game_pressed)
	delete_button.pressed.connect(_on_delete_game_pressed)
