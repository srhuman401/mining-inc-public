class_name SellingUI 
extends ScreenUI

var game_mgr: GameManager

var sellbox_mat_nodes: Dictionary[GameEnum.ResourceType, MaterialNode] = {}
var storage_mat_nodes: Dictionary[GameEnum.ResourceType, MaterialNode] = {}

var max_toggled: bool = false

@export_category("Config")
@export var material_scene: PackedScene
@export var color_red: Color
@export var color_green: Color

@export_category("References")
@export var close_btn: Button
@export var sell_box_container: FlowContainer
@export var storage_box_container: FlowContainer
@export var sell_value: Label
@export var sell_multiplier: Label
@export var max_toggle_btn: Button
@export var sell_btn: Button	

func update_sell_box():
	if !visible: return
	sell_value.text = "Total: $" + str(game_mgr.sell_mgr.get_pay_of_sell_items_in_cash())
	var sell_box = game_mgr.sell_mgr.get_items_in_sell_box()
	print("[SELLUI] Debug items in sell_box: ", sell_box)
	for resource in GameEnum.ResourceType.values():
		var amount = sell_box.get(resource, 0)
		var node: MaterialNode = sellbox_mat_nodes.get(resource)
		node.set_info(resource, amount)

func update_resource(resource: GameEnum.ResourceType):
	if !game_mgr.sell_mgr.is_sellable(resource): return
	print("[SELLUI] Updating resource ", resource)
	var amount = game_mgr.resources.get_resource(resource)
	print("[SELLUI] Debug amount of resource ", resource, ": ", amount)
	var mat_node: MaterialNode = storage_mat_nodes.get(resource)
	if mat_node:
		mat_node.set_info(resource, amount)

func _visibility_changed():
	if visible:
		update_sell_box()
		for resource in GameEnum.ResourceType.values():
			update_resource(resource)

func _ready():
	if !Game.game_manager:
		await Game.game_manager_ready
	game_mgr = Game.game_manager
	
	for resource in GameEnum.ResourceType.values():
		var scene: MaterialNode = material_scene.instantiate()
		var scene2: MaterialNode = material_scene.instantiate()
		storage_box_container.add_child(scene)
		sell_box_container.add_child(scene2)
		
		storage_mat_nodes.set(resource, scene)
		sellbox_mat_nodes.set(resource, scene2)
		
		scene.set_info(resource, 0)
		scene.clicked.connect(func():
			var amount = 1
			if max_toggled:
				amount = game_mgr.resources.get_resource(resource)
			game_mgr.sell_mgr.add_resources_to_sell(resource, amount)
		)
		
		scene2.set_info(resource, 0)
		scene2.clicked.connect(func():
			var amount = 1
			if max_toggled:
				amount = game_mgr.resources.get_resource(resource)
			game_mgr.sell_mgr.remove_resources_from_sell(resource, amount) 
		)
		
		update_resource(resource)
	
	game_mgr.game_events.sell_items_changed.connect(update_sell_box)
	game_mgr.resources.resource_changed.connect(func(resource: GameEnum.ResourceType):
		if !visible: return
		update_resource(resource)
	)
	
	visibility_changed.connect(_visibility_changed)
	
	close_btn.pressed.connect(func():
		ui_root.show_default_screen()
	)
	
	max_toggle_btn.self_modulate = color_red
	max_toggle_btn.pressed.connect(func():
		max_toggled = !max_toggled
		if max_toggled:
			max_toggle_btn.self_modulate = color_green
		else:
			max_toggle_btn.self_modulate = color_red
			
	)
	
	sell_btn.pressed.connect(func():
		game_mgr.sell_mgr.sell_all_items()
	)
