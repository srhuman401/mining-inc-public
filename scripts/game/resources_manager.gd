class_name Resources extends Node

@export var manager: GameManager

signal resource_changed(type: GameEnum.ResourceType)

func set_resource(res: GameEnum.ResourceType, value: int):
	if value <= 0:
		value = 0
	if value >= 999_999:
		value = 999_999
	Game.active_state.resources_stored.set(res, value)
	resource_changed.emit(res)

func get_resource(res: GameEnum.ResourceType) -> int:
	return Game.active_state.resources_stored.get(res, 0)

func adj_resource(res: GameEnum.ResourceType, amount: int):
	var current := get_resource(res)
	current += amount
	set_resource(res, current)

func can_afford_recipe(recipe: GameRecipe) -> bool:
	for resource in recipe.items:
		var amount_of = recipe.items[resource]
		if get_resource(resource) < amount_of:
			return false
	return true

func subtract_recipe(recipe: GameRecipe):
	for resource in recipe.items:
		var amount_of = recipe.items[resource]
		if get_resource(resource) >= amount_of:
			adj_resource(resource, amount_of)
