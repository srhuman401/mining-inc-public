class_name GameUI
extends CanvasLayer

@export var screen_holder: Control
@export var popup_holder: Control
@export var popup_background: Control
@export var is_main_menu: bool = false

var current: ScreenUI
var popup_stack: Array[Control] = []
var transitioning: bool = false

enum Screen
{
	HUD = 1,
	BASE_UPGRADE,
	PAUSE_MENU,
	SETTINGS,
	SMELTING,
	RESEARCH,
	SELLING,
	
	MM_NONE = 100,
	MM_SETTINGS,
	MM_SLOTS,
}

const DEFAULT: Screen = Screen.HUD
const MM_DEFAULT: Screen = Screen.MM_NONE

func set_popup_background(enabled: bool):
	if enabled:
		popup_background.visible = true
		popup_background.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		popup_background.visible = false
		popup_background.mouse_filter = Control.MOUSE_FILTER_IGNORE

func show_default_screen():
	if is_main_menu:
		show_screen(MM_DEFAULT)
		return
	show_screen(DEFAULT)

func show_screen(screen: Screen):
	if transitioning: return
	
	var target: ScreenUI
	
	for screen_ui in screen_holder.get_children():
		if screen_ui is ScreenUI:
			if screen_ui.screen_id == screen: 
				target = screen_ui
				break
	
	if current:
		current.visible = false
	
	if target:
		current = target
		target.visible = true
		if target.transition:
			transitioning = true
			
			await target.transition.show_transition()
			transitioning = false

func pop_popup():
	var latest = popup_stack.get(0)
	if latest != null:
		latest.queue_free()
		popup_stack.erase(latest)
	var next = popup_stack.get(0)
	if next != null:
		set_popup_background(true)
		next.visible = true
	else:
		set_popup_background(false)

func push_popup(popup: Control):
	set_popup_background(true)
	for other_popup in popup_stack:
		other_popup.visible = false
	popup.visible = true
	popup_stack.append(popup)

func _ready():
	set_popup_background(false)
	show_screen(Screen.HUD)
