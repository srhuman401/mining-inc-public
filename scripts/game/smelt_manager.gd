class_name GameSmeltingManager
extends Node

@export var manager: GameManager
var time_until_consume_fuel: float # not in save state cuz who cares
@export var consume_fuel_timer: float = 0.5

func _ready():
	time_until_consume_fuel = consume_fuel_timer

func _process(delta: float):
	var state = Game.active_state
	if state.is_smelting and state.smelting_fuel >= 1:
		time_until_consume_fuel -= delta
		while time_until_consume_fuel <= 0:
			time_until_consume_fuel += consume_fuel_timer
			state.smelting_fuel -= 1
			if state.smelting_fuel < 1:
				return
		state.smelting_time_left -= delta
		manager.game_events.emit_smelt_status_changed()
		if state.smelting_time_left <= 0:
			finish_smelting()

func get_smelting_time() -> float:
	var smelting_time: float = Game.smelting_config.smelt_time
	var num_furnaces := manager.entity.get_entities_of_type(GameEnum.Entity.FURNACE_1).size()as float
	
	smelting_time -= num_furnaces
	if smelting_time <= 0.0: return 0.5
	
	return smelting_time

func finish_smelting():
	var state = Game.active_state
	state.is_smelting = false
	state.smelting_time_left = get_smelting_time()
	for resource in state.queued_smelting_rewards:
		var result: FurnaceSmeltingResult = state.queued_smelting_rewards.get(resource)
		manager.resources.adj_resource(result.reward, result.amount)
	state.queued_smelting_rewards.clear()
	manager.game_events.emit_smelt_queue_changed()

func get_smelting_d(resource: GameEnum.ResourceType):
	return Database.get_res_d(resource).smelting_data

func get_smelt_result(resource: GameEnum.ResourceType):
	return get_smelting_d(resource).smelt_into

func is_smeltable(resource: GameEnum.ResourceType):
	return get_smelting_d(resource).smeltable_type == GameResourceSmeltingData.SmeltableType.RECIPE

func is_fuel(resource: GameEnum.ResourceType):
	return get_smelting_d(resource).smeltable_type == GameResourceSmeltingData.SmeltableType.FUEL

func get_fuel(resource: GameEnum.ResourceType) -> int:
	return get_smelting_d(resource).give_fuel

func can_use_smelting() ->  bool:
	return manager.entity.get_entities_of_type(GameEnum.Entity.FURNACE_1).size() >= 1

func add_to_fuel(resource: GameEnum.ResourceType, amount: int = 1, dont_take_resource: bool = false):
	if !is_fuel(resource): return
	
	if !dont_take_resource:
		if manager.resources.get_resource(resource) < amount:
			return
		manager.resources.adj_resource(resource, -amount)
	
	var state = Game.active_state
	state.smelting_fuel += (get_fuel(resource) * amount)

func add_to_queue(resource: GameEnum.ResourceType, amount: int = 1, dont_take_resource: bool = false):
	if !is_smeltable(resource): return
	
	if !dont_take_resource:
		if manager.resources.get_resource(resource) < amount:
			return
		manager.resources.adj_resource(resource, -amount)
	
	var state = Game.active_state
	var queued: FurnaceSmeltingResult = state.queued_smelting_rewards.get(resource)
	if queued == null:
		queued = FurnaceSmeltingResult.create(get_smelt_result(resource), amount)
		state.queued_smelting_rewards.set(resource, queued)
	else:
		queued.amount += amount
	manager.game_events.emit_smelt_queue_changed()
	state.is_smelting = true
	state.smelting_time_left = get_smelting_time()
