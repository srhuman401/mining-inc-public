extends Button

func _on_self_pressed():
	Game.try_save_active_game()
	Game.return_to_menu(false)

func _ready():
	pressed.connect(_on_self_pressed)
