extends Label

@export var manager: GameManager

func update_label():
	text = "Company Level: " + str(Game.active_state.company_level)

func _ready():
	manager.game_events.level_changed.connect(update_label)
	update_label()
