class_name MenuSmeltingUI extends ScreenUI

@export var close_button: Button
@export var mode_available: Control
@export var mode_unavailable: Control

@export_category("Can Stuff")
@export var num_furnace_display: Label
@export var currently_smelting_display: Label
@export var max_button: Button

@export_category("Elements")
@export var smelting_list_display: HBoxContainer
@export var materials_list_flow_display: FlowContainer
@export var element_list_material: PackedScene

@export_category("Colors")
@export var green: Color
@export var red: Color

var smelting_queue_nodes: Dictionary[GameEnum.ResourceType, SmeltingMaterialNode] = {}
var resources_nodes: Dictionary[GameEnum.ResourceType, SmeltingMaterialNode] = {}
var enable_smelt_max: bool = false

func _ready() -> void:
	visibility_changed.connect(_on_self_visibility_changed)
	close_button.pressed.connect(_on_close_button_pressed)
	max_button.pressed.connect(func():
		set_enable_max_add(!enable_smelt_max)
	)
	set_enable_max_add(false)
	
	if Game.game_manager == null:
		await Game.game_manager_ready
	Game.game_manager.resources.resource_changed.connect(_on_resources_resource_changed)
	
	self.add_all_resources()
	
	Game.game_manager.game_events.smelt_status_changed.connect(smelting_status_update)
	Game.game_manager.game_events.smelt_queue_changed.connect(update_smelting_queue)
	smelting_status_update(true)

func _on_resources_resource_changed(resource: GameEnum.ResourceType):
	var amount: int = Game.game_manager.resources.get_resource(resource)
	var node: SmeltingMaterialNode = resources_nodes.get(resource)
	
	if node:
		node.set_info(resource, amount)

func try_add_resource(resource: GameEnum.ResourceType):
	var is_fuel = Game.game_manager.smelting.is_fuel(resource)
	var is_smeltable = Game.game_manager.smelting.is_smeltable(resource)
	if is_smeltable || is_fuel:
		var res_node: SmeltingMaterialNode = element_list_material.instantiate()
		materials_list_flow_display.add_child(res_node)
		resources_nodes.set(resource, res_node)
		res_node.set_info(resource, Game.game_manager.resources.get_resource(resource))
		if is_smeltable:
			res_node.clicked.connect(func():
				var amount: int = 1
				if enable_smelt_max:
					amount = Game.game_manager.resources.get_resource(resource)
				if amount <= 0: return
				Game.game_manager.smelting.add_to_queue(resource, amount)
				smelting_status_update()
			)
		elif is_fuel:
			res_node.clicked.connect(func():
				var amount: int = 1
				if enable_smelt_max:
					amount = Game.game_manager.resources.get_resource(resource)
				if amount <= 0: return
				Game.game_manager.smelting.add_to_fuel(resource, amount)
				smelting_status_update()
			)

func smelting_status_update(forced: bool = false):
	if !visible && !forced: return
	
	var state = Game.active_state
	#var smeltinger = Game.game_manager.smelting
	currently_smelting_display.text = str(state.smelting_fuel) + " FUEL | " + str(int(state.smelting_time_left)) + "s LEFT"

func create_queue_node(resource: GameEnum.ResourceType):
	if smelting_queue_nodes.has(resource): return
	var new_node: SmeltingMaterialNode = element_list_material.instantiate()
	smelting_list_display.add_child(new_node)
	smelting_queue_nodes.set(resource, new_node)
	new_node.set_info(resource, 1)

func remove_queue_node(resource: GameEnum.ResourceType):
	if !smelting_queue_nodes.has(resource): return
	var node: Node = smelting_queue_nodes.get(resource)
	node.queue_free()
	smelting_queue_nodes.erase(resource)

func update_smelting_queue():
	if !visible: return
	
	var state = Game.active_state
	for resource in state.queued_smelting_rewards:
		create_queue_node(resource)
	for resource in smelting_queue_nodes.keys():
		var sm_node: SmeltingMaterialNode = smelting_queue_nodes.get(resource)
		if not state.queued_smelting_rewards.has(resource):
			remove_queue_node(resource)
			continue
		var reward: FurnaceSmeltingResult = state.queued_smelting_rewards.get(resource)
		sm_node.set_info(resource, reward.amount)

func add_all_resources() -> void:
	for resource in GameEnum.ResourceType.values():
		try_add_resource(resource)

func set_enable_max_add(enable: bool):
	enable_smelt_max = enable
	if enable:
		max_button.self_modulate = green
	else:
		max_button.self_modulate = red

func _on_close_button_pressed():
	self.ui_root.show_default_screen()

func _on_self_visibility_changed():
	if visible:
		update_smelting_queue()
		var num_furnaces := Game.game_manager.entity.get_entities_of_type(
			GameEnum.Entity.FURNACE_1
		).size()
		if num_furnaces >= 1:
			mode_available.visible = true
			mode_unavailable.visible = false
			if num_furnaces > 1:
				num_furnace_display.text = str(num_furnaces) + " FURNACE"
			else:
				num_furnace_display.text = str(num_furnaces) + " FURNACES"
		else:
			mode_available.visible = false
			mode_unavailable.visible = true
