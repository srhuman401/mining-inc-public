class_name MaterialNode
extends Control

@export var res_icon: TextureRect
@export var res_amount: Label
@export var button_element: Button

signal clicked

func set_info(resource: GameEnum.ResourceType, amount: int):
	res_amount.text = str(amount)
	res_icon.texture = GameUtility.get_resource_icon(resource)
	visible = amount > 0

func _ready():
	self.button_element.pressed.connect(func():
		clicked.emit()
)
