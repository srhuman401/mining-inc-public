class_name BaseUpgradeUI extends ScreenUI

@export var display_node_scene: PackedScene

@export var close_button: Button
@export var upgrade_button: Button

@export var rewards_container: Control
@export var rewards_hbox: HBoxContainer

@export var require_container: Control
@export var require_hbox: HBoxContainer

@export var level_label: Label

var game_manager: GameManager
var upgrade_manager: GameUpgradeManager

var current_require_nodes: Array[UpgradeNodeDisplay] = []
var current_reward_nodes: Array[UpgradeNodeDisplay] = []

func close_menu():
	if ui_root != null:
		ui_root.show_default_screen()

func try_upgrade() -> bool:
	if upgrade_manager == null: return false
	
	if upgrade_manager.can_upgrade():
		return true
	
	return false

func create_new_node(array: Array) -> UpgradeNodeDisplay:
	var instance = display_node_scene.instantiate()
	array.append(instance)
	return instance

func upgrade_button_presed():
	var success := try_upgrade()
	if success:
		pass #TODO: success noise
	else:
		pass #TODO: failure noise

func refresh_requirements():
	if upgrade_manager == null: return
	for thing in current_reward_nodes:
		thing.queue_free()
	current_reward_nodes.clear()
	
	var next_upgrade = upgrade_manager.get_next_upgrade()
	if next_upgrade:
		for resource in next_upgrade.resource_requirements:
			var amount: int = next_upgrade.resource_requirements[resource]
			var node = create_new_node(current_reward_nodes)
			require_hbox.add_child(node)
			node.show_resource_requirement(resource, amount)
		for info in next_upgrade.extra_requirement_info:
			var node = create_new_node(current_reward_nodes)
			require_hbox.add_child(node)
			node.show_extra_info(info)

func refresh_rewawrds():
	if upgrade_manager == null: return
	for thing in current_require_nodes:
		thing.queue_free()
	current_require_nodes.clear()
	
	var next_upgrade = upgrade_manager.get_next_upgrade()
	if next_upgrade:
		for item_id in next_upgrade.shown_item_unlocks:
			var node = create_new_node(current_require_nodes)
			rewards_hbox.add_child(node)
			node.show_item_reward(item_id)

func refresh_upgrade():
	refresh_rewawrds()
	refresh_requirements()

func _ready():
	await Game.game_manager_ready
	game_manager = Game.game_manager
	
	if game_manager:
		upgrade_manager = game_manager.upgrade_manager
	
	if close_button: close_button.pressed.connect(close_menu)
	if upgrade_button: upgrade_button.pressed.connect(upgrade_button_presed)
	game_manager.game_events.level_changed.connect(refresh_upgrade)
	refresh_upgrade()
