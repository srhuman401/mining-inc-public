extends Node2D

@onready var anim_player = $AnimationPlayer

func _ready():
	await get_tree().process_frame
	anim_player.play(&"animation")
	await anim_player.animation_finished
	SceneLoader.enter_scene(ScenePaths.MAIN_MENU)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			anim_player.play("RESET")
