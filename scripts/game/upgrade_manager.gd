class_name GameUpgradeManager extends Node

@export var manager: GameManager

# NOTE: this doesnt load an upgrade state, it adds upgrade values into the game state.
# So doing the same upgrade twice will cause a bug, since that will duplicate the values
func load_upgrade(upgrade_index: int):
	var game_state = Game.active_state
	if game_state == null or game_state.company_level == upgrade_index:
		print("[upgrade mgr] Failed to upgrade: No game state or already that level.")
		return
	
	if Game.CONFIG.GAME_UPGRADES.size() < upgrade_index:
		print("[upgrade mgr] Failed to upgrade: upgrade does not exist for that index")
		return
	
	var upgrade_data: GameBaseUpgrade = Game.CONFIG.GAME_UPGRADES.get(upgrade_index)
	if upgrade_data != null:
		print("[upgrade mgr] Succeeded: upgrade does exist")
		game_state.company_level = upgrade_index
		
		game_state.area_width += upgrade_data.remove_fog_width
		game_state.area_height += upgrade_data.remove_fog_height
		
		if upgrade_data.do_set_pickaxe == true:
			game_state.pickaxe_type = upgrade_data.set_pickaxe_to
		
		for mod in upgrade_data.modifiers:
			mod.redeem()
		
		manager.game_events.emit_level_changed()

func get_next_upgrade() -> GameBaseUpgrade:
	var index := Game.active_state.company_level + 1
	if index < 0 or index >= Game.CONFIG.GAME_UPGRADES.size():
		return null
	return Game.CONFIG.GAME_UPGRADES[index]

func is_max_level() -> bool:
	var game_state = Game.active_state
	if game_state == null: return false
	
	if game_state.company_level >= Game.CONFIG.max_company_level:
		return true
	
	return false

func can_upgrade() -> bool:
	if is_max_level(): return false
	
	var game_state = Game.active_state
	if game_state == null: return false
	
	var next_upgrade_index = game_state.company_level + 1
	
	if Game.CONFIG.GAME_UPGRADES.size() <= next_upgrade_index:
		print("[upgrade mgr] Max level")
		return false
	var upgrade_data: GameBaseUpgrade = Game.CONFIG.GAME_UPGRADES.get(next_upgrade_index)
	
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

func try_and_upgrade():
	if can_upgrade():
		load_upgrade(Game.active_state.company_level + 1)
	else:
		print("[upgrade mgr] Failed to upgrade: Requirements not met")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("DEBUG_INPUT_1"):
		load_upgrade(Game.active_state.company_level + 1)
