extends Button

@export var slot_to_load: int = 1
@export var loading_screen: CanvasLayer

func _on_self_pressed():
	if Game.slot_content_exists(slot_to_load) == false:
		Game.new_game_slot(slot_to_load, 1)
	
	if loading_screen != null:
		loading_screen.visible = true
	
	Game.request_slot_content(slot_to_load, func(success: bool, res: GameState, slot: int):
		if loading_screen: loading_screen.visible = false
		if success:
			Game.enter_game_slot(res, slot)
	)

func _ready():
	pressed.connect(_on_self_pressed)
