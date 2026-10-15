class_name MainMenuUIManager extends CanvasLayer

@export var screens: Dictionary[String, Control] = {}

func set_screen(screen: String):
	for screen_name in screens:
		var control: Control = screens.get(screen_name)
		control.visible = screen_name == screen
