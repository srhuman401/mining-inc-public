extends Button

@export var screen_name: String = ""
@export var manager: MainMenuUIManager

func _ready():
	pressed.connect(_on_self_pressed)

func _on_self_pressed():
	manager.set_screen(screen_name)
