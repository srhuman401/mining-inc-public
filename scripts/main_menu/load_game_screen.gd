class_name LoadGameScreen extends Control

var ui_map: Dictionary[int, SaveSlotUI] = {}

@export var vbox_cont: VBoxContainer
@export var loading_screen: CanvasLayer
@export var enter_name: NameEntryPrompt

func create_slot(slot: int):
	enter_name.prompt()
	var result: NameEntryPrompt.Result = await enter_name.prompt_submitted
	if !result.success:
		return
	
	var company_name = result.enter_name
	
	Game.new_game_slot(slot, 1)
	
	var meta = Game.retrieve_slot_meta(slot)
	meta.company_name_string = company_name
	Game._save_meta_data(slot, meta)
	
	var ui: SaveSlotUI = ui_map.get(slot)
	if ui != null: ui.refresh()

func delete_slot(slot: int):
	Game.force_delete_slot(slot)
	var ui: SaveSlotUI = ui_map.get(slot)
	if ui != null: ui.refresh()

func load_slot(slot: int):
	loading_screen.visible = true
	Game.request_slot_content(slot, func(worked: bool, res: GameState, _slot: int):
		loading_screen.visible = false
		if worked: Game.enter_game_slot(res, slot)
		)

func _ready() -> void:
	for i in range(Game.MAX_GAME_SLOTS):
		var slot = i + 1
		var slot_ui: SaveSlotUI = preload("res://scenes/main_menu/save_slot.tscn").instantiate()
		
		vbox_cont.add_child(slot_ui)
		slot_ui.slot = slot
		slot_ui.holder_screen = self
		slot_ui.refresh()
		
		ui_map.set(slot, slot_ui)
