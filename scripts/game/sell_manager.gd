class_name GameSellManager
extends Node

@export var manager: GameManager
@onready var game_state := Game.active_state

func _ready():
	if Game.game_manager == null:
		await Game.game_manager_ready
	
	# DEBUGGING
	manager.game_events.sell_items_changed.connect(func():
		print("[sell mgr] Debug sell list: ", game_state.resources_to_sell,  "--------\nThat will pay: ", str(get_pay_of_sell_items_in_cash()))
		)

func get_sell_d(resource: GameEnum.ResourceType):
	return Database.get_res_d(resource).sell_data

func is_sellable(resource: GameEnum.ResourceType) -> bool:
	return get_sell_d(resource).is_sellable 

func add_resources_to_sell(resource: GameEnum.ResourceType, amount: int = 1):
	if !is_sellable(resource): return
	
	var amount_of_resource = manager.resources.get_resource(resource)
	if amount_of_resource < amount:
		print("[sell mgr] Tried to add more resources to sell but dont have enough of attempted resource. Cancelling.")
		return
	
	var cur_amount = game_state.resources_to_sell.get(resource, 0)
	game_state.resources_to_sell.set(resource, cur_amount + amount)
	manager.resources.adj_resource(resource, -amount)
	manager.game_events.emit_sell_items_changed()

func remove_resources_from_sell(resource: GameEnum.ResourceType, amount: int = 1):
	if !is_sellable(resource): return
	
	var cur_amount = game_state.resources_to_sell.get(resource, 0)
	if cur_amount < 0:
		print("[sell mgr] Remove resources from sell failed. Tried to remove more than what is stored")
		return
	
	game_state.resources_to_sell.set(resource, cur_amount - amount)
	manager.resources.adj_resource(resource, amount)
	manager.game_events.emit_sell_items_changed()

func sell_all_items():
	if game_state.resources_to_sell.size() <= 0:
		print("[sell mgr] Failed to sell: no resources are in the box")
		return
	
	var pay = get_pay_of_sell_items()
	game_state.resources_to_sell.clear()
	
	for res in pay:
		var amount = pay[res]
		manager.resources.adj_resource(res, amount)
	
	manager.game_events.emit_sell_items_changed()
	manager.game_events.emit_sold_items()

func get_items_in_sell_box() -> Dictionary[GameEnum.ResourceType, int]:
	return game_state.resources_to_sell

func get_pay_of_sell_items() -> Dictionary[GameEnum.ResourceType, int]:
	var totals: Dictionary[GameEnum.ResourceType, int] = {}
	
	for resource_en in game_state.resources_to_sell:
		var res_amount = game_state.resources_to_sell.get(resource_en, 0)
		var res_value = get_sell_d(resource_en).sell_value
		var total = (res_value * res_amount) * game_state.sell_multiplier
		totals.set(get_sell_d(resource_en).sell_resource, floori(total))
	
	return totals

func get_pay_of_sell_items_in_cash() -> int:
	return get_pay_of_sell_items().get(GameEnum.ResourceType.CURRENCY_MONEY, 0)
