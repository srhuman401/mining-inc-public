extends Button

@export var screen_ui: ScreenUI
@export var set_to: GameUI.Screen

func _on_self_pressed():
	screen_ui.ui_root.show_screen(set_to)

func _ready():
	if screen_ui != null:
		pressed.connect(_on_self_pressed)
