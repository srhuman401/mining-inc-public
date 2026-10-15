extends Button


func _on_pressed():
	Game.new_game_slot(1, 0)

func _ready():
	pressed.connect(_on_pressed)
