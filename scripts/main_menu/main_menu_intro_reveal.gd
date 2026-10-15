extends Node2D

@export var logo: TextureRect
@export var main_menu_control: Control
@export var animator: AnimationPlayer
@export var enabled: bool = true
@export_category("Sounds")
@export var menu_music: AudioStreamPlayer
@export var reveal_sound: AudioStreamPlayer

func _ready():
	if enabled and !Game.already_shown_intro:
		Game.already_shown_intro = true
		main_menu_control.visible = false
		logo.modulate = 0
		
		animator.play(&"reveal")
		reveal_sound.play()
		await animator.animation_finished
		print("Hi")
	
		main_menu_control.visible = true
	menu_music.play()
