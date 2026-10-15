extends Button

func _ready() -> void:
	pressed.connect(_on_self_pressed)

func _on_self_pressed() -> void:
	await get_tree().process_frame
	get_tree().quit()
