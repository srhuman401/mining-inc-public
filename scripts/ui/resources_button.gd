extends Button

@export var toggle_frame: Control
@export var start_visible: bool = false

func _on_self_pressed():
	toggle_frame.visible = !toggle_frame.visible

func _ready():
	toggle_frame.visible = start_visible == true
	pressed.connect(_on_self_pressed)
