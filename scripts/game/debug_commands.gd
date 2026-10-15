class_name GameDebugCommandsManager
extends Node

var typing_cmd: String = ""
var cmd_active: bool = false
var game_mgr: GameManager

@export var display: CanvasLayer
@export var display_typing_cmd: Label

func _ready():
	if !Game.game_manager:
		await Game.game_manager_ready
	game_mgr = Game.game_manager

func set_active(active: bool):
	typing_cmd = ""
	display.visible = active
	cmd_active = active

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("DEBUG_COMMAND_BAR"):
		set_active(!cmd_active)

func _input(event: InputEvent) -> void:
	if !cmd_active:
		return
	if event.is_action_pressed("DEBUG_COMMAND_BAR"):
		return

	if event is InputEventKey and event.pressed:
		if event.unicode > 0:
			typing_cmd += char(event.unicode)

		if event.keycode == KEY_BACKSPACE and typing_cmd.length() > 0:
			typing_cmd = typing_cmd.substr(0, typing_cmd.length() - 1)

		if event.keycode == KEY_ENTER:
			parse_command()
			typing_cmd = ""

		display_typing_cmd.text = typing_cmd

func parse_command():
	var arguments: PackedStringArray = typing_cmd.split(" ")
	var command_name: String = arguments[0]
	redeem_command(command_name, arguments)

func redeem_command(command_name: String, arguments: PackedStringArray):
	match command_name:
		"changeresource":
			if arguments.size() < 3:
				return
			var resource_id_arg: String = arguments[1]
			var amount_to_add_arg: String = arguments[2]
			var resource_id: GameEnum.ResourceType
			for key in GameEnum.ResourceType.keys():
				if resource_id_arg == key:
					resource_id = GameEnum.ResourceType[key]
					break
			if resource_id == null: return
			if resource_id == -1: return
			var amount_to_add: int = int(amount_to_add_arg)
			game_mgr.resources.adj_resource(resource_id, amount_to_add)
		"iwantmoney":
			Game.active_meta.slot_has_cheats = true
			game_mgr.resources.adj_resource(GameEnum.ResourceType.CURRENCY_MONEY, 1_000)
		"beginplacingitem":
			print("BeginPlacingItem commanded")
			if arguments.size() < 2:
				return
			set_active(false)
			var item_id: String = arguments[1]
			if Database.get_item(item_id) != null:
				game_mgr.placement.begin_placement(item_id)
		
		"freeupgrades":
			Game.active_meta.slot_has_cheats = true
			game_mgr.active_cheats.ignore_upgrade_requirements = true
		"nextbaselevel":
			game_mgr.upgrade_manager.load_upgrade(
				Game.active_state.company_level + 1
			)
		"entitydelete":
			if arguments.size() < 2:
				pass
			var entity_id: int = int(arguments[1])
			if game_mgr.entity.get_entity(entity_id) != null:
				game_mgr.entity.remove_entity(entity_id)
		"entitylist":
			for handle in Game.active_state.map_state.entity_map:
				var entity_data = Game.active_state.map_state.entity_map[handle]
				print("[ENTITY LIST] [ID: ",handle,"] ", entity_data, " | TYPE ",entity_data.type," | STATE ",entity_data.state)
		"test-sell":
			if arguments.size() < 2:
				pass
			var act := String(arguments[1])
			var debug_res = GameEnum.ResourceType.COAL_RAW
			if act == "1":
				game_mgr.sell_mgr.add_resources_to_sell(debug_res, 1)
			elif act == "2":
				game_mgr.sell_mgr.remove_resources_from_sell(debug_res, 1)
			elif act == "3":
				game_mgr.sell_mgr.sell_all_items()
