class_name UIButtonHover 
extends Node

var attached: Button

@export var hover_scale: float = 1.1
@export var speed: float = 10.0

var target_scale := Vector2.ONE

func get_random_pitch() -> float:
	return randf_range(0.8, 1.1)

func _ready():
	var parent = get_parent()
	if parent is Button:
		parent.pivot_offset = parent.size/2
		attached = parent
		attached.mouse_entered.connect(_on_hover)
		attached.mouse_exited.connect(_on_stop_hover)
		attached.pressed.connect(_on_pressed)

func _on_pressed():
	SoundManager.play_ui_sound_with_pitch(
		Sounds.UI_BTN_CLICK,
		get_random_pitch()
	).volume_db /= 2

func _on_hover():
	target_scale = Vector2.ONE * hover_scale
	SoundManager.play_ui_sound_with_pitch(
		Sounds.UI_BTN_HOVER,
		get_random_pitch()
	)

func _on_stop_hover():
	target_scale = Vector2.ONE
	pass


func _process(delta: float) -> void:
	if attached == null: return	
	attached.scale = attached.scale.lerp(target_scale, delta * speed)
