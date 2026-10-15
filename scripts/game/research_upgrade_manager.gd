class_name GameResearchManager extends Node

@export var manager: GameManager

# NOTE: this doesnt load an upgrade state, it adds upgrade values into the game state.
# So doing the same upgrade twice will cause a bug, since that will duplicate the values
func load_upgrade(upgrade_index: int):
	var game_state = Game.active_state
	if game_state == null or game_state.company_level == upgrade_index:
		print("[research mgr] Failed to upgrade: No game state or already that level.")
		return
	
	if Game.research_config.upgrades.size() < upgrade_index:
		print("[research mgr] Failed to upgrade: upgrade does not exist for that index")
		return
	
	var upgrade_data: BaseResearchUpgrade = Game.research_config.upgrades.get(upgrade_index)
	if upgrade_data != null:
		print("[research mgr] Succeeded: upgrade does exist")
		game_state.research_level = upgrade_index
		
		game_state.area_width += upgrade_data.remove_fog_width
		game_state.area_height += upgrade_data.remove_fog_height
		
		for mod in upgrade_data.modifiers:
			mod.redeem()
		
		manager.game_events.emit_level_changed()

func get_next_upgrade() -> BaseResearchUpgrade:
	var index := Game.active_state.research_level + 1
	if index < 0 or index >= Game.research_config.upgrades.size():
		return null
	return Game.research_config.upgrades[index]

func is_max_level() -> bool:
	var game_state = Game.active_state
	if game_state == null: return false
	
	if game_state.research_level >= Game.CONFIG.max_research_level:
		return true
	
	return false

func can_upgrade() -> bool:
	if is_max_level(): return false
	
	var game_state = Game.active_state
	if game_state == null: return false
	
	if game_state.is_researching_active: return false
	
	var next_upgrade_index = game_state.research_level + 1
	
	if Game.research_config.upgrades.size() <= next_upgrade_index:
		print("[research mgr] Max level")
		return false
	var upgrade_data: BaseResearchUpgrade = Game.research_config.upgrades.get(next_upgrade_index)
	
	if upgrade_data == null: return false
	
	if manager.active_cheats.ignore_upgrade_requirements == false:
		for resource in upgrade_data.resource_requirements:
			var required_amount: int = upgrade_data.resource_requirements.get(resource)
			var player_amount: int = manager.resources.get_resource(resource)
			
			if player_amount < required_amount:
				return false
		
		for required_flag in upgrade_data.required_flags:
			if game_state.game_flags.get(required_flag) != true:
				return false
	
	return true

func _process(delta: float) -> void:
	var state = Game.active_state
	if !state: return
	if state.is_researching_active:
		state.researching_time_left -= delta
		if state.researching_time_left <= 0:
			state.is_researching_active = false
			state.researching_time_left = false
			load_upgrade(state.research_level + 1)
		manager.game_events.emit_researching_status_changed()

func get_research_time(next_upgrade: BaseResearchUpgrade) -> float:
	var number_stations: int = manager.placement.get_placed_number_of_entity(
		GameEnum.Entity.RESEARCH_STATION
	)
	return max(
		next_upgrade.base_research_duration / sqrt(number_stations),
		5.0
	)

func has_enough_stations() -> bool:
	return manager.placement.get_placed_number_of_entity(
		GameEnum.Entity.RESEARCH_STATION
	) > 0

func begin_researching():
	var next_upgrade := get_next_upgrade()
	if next_upgrade == null: return
	
	var research_time = get_research_time(next_upgrade)
	
	var state = Game.active_state
	if state == null: return
	
	state.researching_time_left = research_time
	state.is_researching_active = true
	manager.game_events.emit_researching_status_changed()

func try_and_upgrade():
	if can_upgrade():
		begin_researching()
	else:
		print("[research mgr] Failed to upgrade: Requirements not met")
