class_name GameResourceSellingData
extends Resource

@export var is_sellable: bool = false
@export var sell_value: int = 0

@export_category("Fun")
## Allows you to change what this sells into. 
## Note: The game assumes sell_value means money. So this wont look proper in-game.
@export var sell_resource: GameEnum.ResourceType = GameEnum.ResourceType.CURRENCY_MONEY
