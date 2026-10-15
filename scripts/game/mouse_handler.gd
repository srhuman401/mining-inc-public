class_name GameMouseHandler
extends Node

@export var manager: GameManager
@onready var tile_map := manager.tile_map

class MouseHandlerEvent extends RefCounted: 
	var identifier: String = "UNKNOWN_EVENT"
	var callable: Callable
	var disabled: bool = false
	var remove_on_trigger: bool = false
	var priority: int = 9

const CLICK_COOLDOWN: float = 0.1
var click_cooldown_end: float = 0 

# hardcode this shit
var order_of_event_attempts = [
	"PLACEMENT_ACCEPT",
	"ENTITY_CLICK",
	"ORE_MINING",
]

var last_hovered_cell_pos: Vector2i
var last_hovered_tile: GameTileData
var last_hovered_tile_behaviour: GameTileBehaviour
var is_last_hovered_pos_supported: bool = false
var mouse_event_stack: Array[MouseHandlerEvent] = []

signal hover_changed

func _ready():
	add_mouse_event("ORE_MINING", func(tile: GameTileData, behv: GameTileBehaviour, _pos): 
		print("Invoked mine ore with: ", tile == null, " ", behv == null)
		if tile == null: return false
		if behv is OreTileBehaviour:
			var pickaxe_damage: int = Game.CONFIG.PICKAXE_STATS.get(
				Game.active_state.pickaxe_type,
				1
			)
			var worked: bool = behv.damage(tile, pickaxe_damage)
			if worked:
				manager.play_world_sound_at_pos(
					Sounds.PICKAXE_HIT,
					manager.get_cell_world_pos(tile.position),
				)
			return true
		else: return false
	)
	
	# clicking entities
	add_mouse_event("ENTITY_CLICK", func(_tile: GameTileData, _behv: GameTileBehaviour, pos: Vector2i):
		print("[ec] trying to Click entity at", pos)
		var entity = manager.entity.get_entity_at_cell(pos)
		print("[ec] Debug print Entity handle: " , entity)
		if entity != null:
			print("[ec] Exists! (entity)")
			var behv: ClickableEntityBehv = manager.entity.get_ent_behaviour(entity)
			if behv and (behv is ClickableEntityBehv):
				print("[ec] Behv is ClickableEntityBehv. Clicking entity.")
				behv.entity_clicked()
	)
	print_mouse_event_stack()

func get_mouse_event(callable: Callable) -> MouseHandlerEvent:
	for event in mouse_event_stack:
		if event.callable ==  callable:
			return event
	return null

func activate_cooldown():
	click_cooldown_end = Game.time() + CLICK_COOLDOWN

func print_mouse_event_stack():
	var list = []
	for event in mouse_event_stack:
		list.append(event.identifier)
	print(list)

func add_mouse_event(id_name: String, function: Callable, remove_on_trigger: bool = false
):
	var event = MouseHandlerEvent.new()
	event.identifier = id_name
	event.callable = function
	event.remove_on_trigger = remove_on_trigger == true
	#event.priority = priority
	
	mouse_event_stack.append(event)
	#mouse_event_stack.sort_custom(func(a:MouseHandlerEvent, b:MouseHandlerEvent):
	#	return a.priority > b.priority
	#)

func remove_mouse_event(function: Callable):
	var to_remove: MouseHandlerEvent
	for mouse_event in mouse_event_stack:
		if mouse_event.callable == function:
			to_remove = mouse_event
			break
	if to_remove != null: mouse_event_stack.erase(to_remove)

func send_mouse_events(tile: GameTileData, behv: GameTileBehaviour, world_pos: Vector2i):
	var to_remove: MouseHandlerEvent
	for id in order_of_event_attempts:
		print("[mouse] reached event, ", id)
		var mouse_event: MouseHandlerEvent
		for check_event in mouse_event_stack:
			if (check_event as MouseHandlerEvent).identifier == id:
				mouse_event = check_event
				break
					
		if mouse_event == null or mouse_event.disabled == true: continue
		if mouse_event.callable != null:
			var worked = mouse_event.callable.call(tile ,behv, world_pos)
			print("[mouse] triggered event ", id)
			if worked == true:
				print("breaking here")
				if mouse_event.remove_on_trigger == true:
					to_remove = mouse_event
					activate_cooldown()
					break
				
		if to_remove != null and to_remove is MouseHandlerEvent:
			mouse_event_stack.erase(to_remove)

func _unhandled_input(event: InputEvent) -> void:
	if Game.active_state == null: return
	if event is InputEventMouseMotion:
		var map_tile_map := Game.active_state.map_state.tile_map
		var mouse_pos := manager.get_global_mouse_position()
		
		if !manager.fog_rect.inside_rect(mouse_pos):
			is_last_hovered_pos_supported = false
			last_hovered_tile = null
			last_hovered_tile_behaviour = null
			hover_changed.emit()
			return
		
		var local_pos := tile_map.to_local(mouse_pos)
		var cell_pos = tile_map.local_to_map(local_pos)
		var tile: GameTileData = map_tile_map.get(cell_pos)
		
		last_hovered_cell_pos = cell_pos
		
		if tile != null:
			var behv := manager.get_tile_behaviour(tile)
			var cell_below = TileUtility.get_below_cell(cell_pos)
			var tile_below = map_tile_map.get(cell_below)
			
			last_hovered_tile = tile
			last_hovered_tile_behaviour = behv
			
			if TileUtility.is_tile_air(tile) and !TileUtility.is_tile_air(tile_below):
				is_last_hovered_pos_supported = true
			else:
				is_last_hovered_pos_supported = false
		else:
			is_last_hovered_pos_supported = !TileUtility.is_tile_air(map_tile_map.get(TileUtility.get_below_cell(cell_pos)))
			last_hovered_tile = null
			last_hovered_tile_behaviour = null
		hover_changed.emit()
	if event is InputEventMouseButton:
		var time = Game.time()
		if click_cooldown_end > time:
			print("on cooldown: ends in ", click_cooldown_end - time, "s")
			return
		
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_pos = manager.get_global_mouse_position()
			
			if !manager.fog_rect.inside_rect(mouse_pos):
				return
			
			var local_pos = tile_map.to_local(mouse_pos)
			var tile_pos = tile_map.local_to_map(local_pos)
			#print(tile_pos)
			var tile :GameTileData= Game.active_state.map_state.tile_map.get(tile_pos)
			var behv: GameTileBehaviour
			if tile != null:
				behv = manager.get_tile_behaviour(tile)
			print('[mouse] debug1 ', tile, behv)
			send_mouse_events(tile, behv, tile_pos)
