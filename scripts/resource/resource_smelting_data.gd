class_name GameResourceSmeltingData
extends Resource

enum SmeltableType {
	NONE,
	RECIPE,
	FUEL
}

@export var smeltable_type: SmeltableType = SmeltableType.NONE

@export_category("Fuel Type")
@export var give_fuel: int = 10

@export_category("Recipe Type")
@export var smelt_into: GameEnum.ResourceType
