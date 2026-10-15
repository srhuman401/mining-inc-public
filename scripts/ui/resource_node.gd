class_name ResourceNodeUI extends Panel

@export var icon_texture: TextureRect
@export var resource_label: Label
@export var amount_label: Label

func set_resource(resource: GameEnum.ResourceType):
	var icon := GameUtility.get_resource_icon(resource)
	var disp_name := GameUtility.get_resource_name(resource)
	
	if icon:
		icon_texture.texture = icon
	if disp_name:
		resource_label.text = disp_name

func set_display_data(disp: GameResourceDisplayInfo):
	var icon = disp.image
	var dname = disp.display_name
	
	if icon:
		icon_texture.texture = icon
	if dname:
		resource_label.text = dname

func set_amount(amount: int):
	var a_string = GameUtility.format_number(amount)
	amount_label.text = a_string
