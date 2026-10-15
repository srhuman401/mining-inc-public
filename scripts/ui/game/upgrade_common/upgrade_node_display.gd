class_name UpgradeNodeDisplay extends Control

@export var general_mode: Control
@export var general_icon_texture: TextureRect
@export var general_amount_label: Label

@export var tooltip: Control
@export var tooltip_text_label: Label

enum Mode
{
	GENERAL
}

func show_tooltip(make_visible: bool = true):
	tooltip.visible = make_visible

func set_mode(mode: Mode):
	var frames: Array[Control] = [general_mode]
	var frame_visible: int = -1
	
	match mode:
		Mode.GENERAL:
			frame_visible = 0
	
	for index in frames.size():
		var frame := frames[index]
		frame.visible = (frame_visible == index)

func show_resource_requirement(resource: GameEnum.ResourceType, amount: int = 0):
	set_mode(Mode.GENERAL)
	
	var icon_texture := GameUtility.get_resource_icon(resource)
	
	var resource_display_name: String = GameUtility.get_resource_name(
		resource
	)
	
	general_icon_texture.texture = icon_texture
	general_amount_label.text = GameUtility.format_number(amount)
	tooltip_text_label.text = str(amount) + " " + resource_display_name

func show_item_reward(item_position: String):
	var data := Database.get_item(item_position)
	if data:
		set_mode(Mode.GENERAL)
		var item_icon := data.icon_display_image
		if item_icon:
			general_icon_texture.texture = item_icon
		
		general_amount_label.text = "NEW ITEM"
		tooltip_text_label.text = data.display_name

func show_extra_info(info: ExtraUpgradeInfo):
	set_mode(Mode.GENERAL)
	
	if info.icon:
		general_icon_texture.texture = info.icon
	general_amount_label.text = info.title
	tooltip_text_label.text = info.tooltip

func _on_mouse_entered():
	print("Hello")
	show_tooltip(true)

func _on_mouse_exited():
	print("Bye")
	show_tooltip(false)

func _ready():
	show_tooltip(false)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
