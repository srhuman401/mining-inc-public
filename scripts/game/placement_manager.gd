class_name PlacementManager extends Node

@export var manager: GameManager
@export var game_events: GameEvents
@export var mouse_handler: GameMouseHandler

const ENTITYSTATE_PLAYER_BUILT: String = "placement:is_entity_player_built"
const ENTITYSTATE_ITEM_ID_REF: String = "placement:from_item_id"
const ENTITYSTATE_PLACEMENT_GHOST: String = "placement:is_ghost"

var currently_placing: bool = false
var placing_item: GameItemInfo
var placing_type: GameItemInfo.PlacementType
var placement_ghost: int = -1
var can_place_here: bool = false
var placement_actual_position: Vector2i = Vector2i.ZERO
var placing_entity_cfg: EntityDataConfig

func _ready() -> void:
	mouse_handler.add_mouse_event("PLACEMENT_ACCEPT", _on_placement_accept, 2)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		print("Trying to place?")
		begin_placement("drill_tier_2")

func _process(_delta: float) -> void:
	if !currently_placing: return
	if placement_ghost == -1: return
	
	var cell_pos := mouse_handler.last_hovered_cell_pos
	var behv_at_pos := mouse_handler.last_hovered_tile_behaviour
	var tile_at_pos := mouse_handler.last_hovered_tile
	var tile_at_pos_is_supported := mouse_handler.is_last_hovered_pos_supported
	var ghost_entity := manager.entity.get_entity_visual(placement_ghost)
	
	var entity_occupy_offsets := placing_entity_cfg.occupy_tile_offsets
	
	if placing_type == GameItemInfo.PlacementType.DRILL:
		var above_cell := TileUtility.get_above_cell(cell_pos)
		#var below_cell := TileUtility.get_below_cell(cell_pos)
		var above_tile: GameTileData = Game.active_state.map_state.tile_map.get(above_cell)
		var occupied = manager.entity.get_entity_at_cell(cell_pos) != -1
		#var occupied_second = (behv_at_pos is OreTileBehaviour) and manager.entity.get_entity_at_cell(above_cell) != -1
		
		if (behv_at_pos is OreTileBehaviour) and TileUtility.is_tile_air(above_tile) and !occupied:
			can_place_here = true
			placement_actual_position = cell_pos
			manager.entity.set_entity_cell(placement_ghost, above_cell)
		else:
			can_place_here = false
			manager.entity.set_entity_cell(placement_ghost, cell_pos)
	if placing_type == GameItemInfo.PlacementType.BUILDING:
		var not_colliding = true
		
		for offset in entity_occupy_offsets:
			var world := cell_pos + offset
			var _tile_at_pos = Game.active_state.map_state.tile_map.get(world)
			var ent_at_pos = manager.entity.get_entity_at_cell(world)
			var cell_occupied_by_entity = ent_at_pos != -1 && ent_at_pos != placement_ghost
			if offset.y == 0:
				var below_tile = Game.active_state.map_state.tile_map.get(TileUtility.get_below_cell(world))
				if TileUtility.is_tile_air(below_tile):
					not_colliding = false
			if cell_occupied_by_entity or !TileUtility.is_tile_air(_tile_at_pos):
					not_colliding = false
		
		if not_colliding:
			can_place_here = true
			placement_actual_position = cell_pos
			manager.entity.set_entity_cell(placement_ghost, cell_pos)
		else:
			can_place_here = false
			manager.entity.set_entity_cell(placement_ghost, cell_pos)
	
	if ghost_entity != null: set_visual_ghostlike(ghost_entity, can_place_here == true)

func _on_placement_accept(_tile: GameTileData, _behv: GameTileBehaviour, _pos: Vector2i):
	#print("Hello")
	if !currently_placing: return false
	print(can_place_here, can_afford_current_placement())
	if currently_placing && can_place_here && can_afford_current_placement():
		print("Can Place Here. Wow.")
		var handle := manager.entity.create_entity(
			placing_item.entity_id,
			placement_actual_position
		)
		
		var data = manager.entity.get_entity(handle)
		if data != null:
			data.state.set(ENTITYSTATE_PLAYER_BUILT, true)
			data.state.set(ENTITYSTATE_ITEM_ID_REF, placing_item.item_id)
		
		stop_placement()
	return true

## WARNING: Heavy, dont use frequently, can impact peformance!!
func get_placed_number_of_entity(entity: GameEnum.Entity) -> int:
	var array_of_ent := manager.entity.get_entities_of_type(entity)
	var number: int = 0
	
	for handle in array_of_ent:
		var data = manager.entity.get_entity(handle)
		if data and data.state.get(ENTITYSTATE_PLAYER_BUILT) == true:
			number += 1
	
	return number

func stop_placement():
	currently_placing = false
	placing_item = null
	can_place_here = false
	placement_actual_position = Vector2i.ZERO
	if placement_ghost != -1:
		manager.entity.remove_entity(placement_ghost)
		placement_ghost = -1

func _init_placement():
	if !currently_placing or placing_item == null or placing_type == null or placement_ghost != -1:
		print(placement_ghost)
		print("cannot init placement")
		return
	
	placement_ghost = manager.entity.create_entity(
		placing_item.entity_id,
		Vector2i(0,0),
		true,
		true
	)
	manager.entity.get_entity(placement_ghost).state.set(ENTITYSTATE_PLACEMENT_GHOST, true)
	
	var placement_visual: Node = manager.entity.get_entity_visual(placement_ghost)
	if placement_visual != null: set_visual_ghostlike(placement_visual)

func set_visual_ghostlike(visual: Node, can_place: bool = true):
	if visual is Sprite2D or visual is AnimatedSprite2D:
		if can_place:
			visual.modulate = Color(1.0, 1.0, 1.0, 0.41)
		else:
			visual.modulate = Color(1.0, 0.0, 0.0, 0.41)

func can_afford_current_placement() -> bool:
	if !currently_placing: return false
	if placing_item == null: return false
	
	if manager.active_cheats.ignore_placement_requirements:
		return true
	
	for resource in placing_item.recipe:
		var amount = placing_item.recipe.get(resource, 0)
		var plr_amount = manager.resources.get_resource(resource)
		
		if plr_amount < amount: return false
		
	return true

func begin_placement(item: String):
	if currently_placing: return
	var item_info = Database.get_item(item)
	if item_info != null:
		can_place_here = false
		currently_placing = true
		placement_actual_position = Vector2i.ZERO
		placing_item = item_info
		placing_type = item_info.placement_type
		placing_entity_cfg = Database.get_ent_cfg(item_info.entity_id)
		_init_placement()
