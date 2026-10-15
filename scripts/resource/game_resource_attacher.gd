class_name GameResourceAttacher 
extends Resource

## Binds this datafolder to the resource enum here.
## This will make the game use this datafolder for things related to the enum
@export var for_resource_enum: GameEnum.ResourceType

@export_category("Components")
@export var smelt_behaviour: GameResourceSmeltingData
@export var display_behaviour: GameResourceDisplayInfo
@export var sell_behaviour: GameResourceSellingData
