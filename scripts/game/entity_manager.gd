class_name EntityManager extends Node

@onready var entities: Dictionary[int, GameEntityData] = Game.active_state.map_state.entity_map
var entitys_visualized: Dictionary[int, Node] = {}
var active_entities: Array[int] = []

var entity_by_cell: Dictionary[Vector2i, int]

var disable_entity_occupy_multiple_cells: bool = false

@export var background_entity_visual_container: EntityContainer
@export var foreground_entity_visual_container: EntityContainer

func next_id():
	Game.active_state.next_entity_id += 1
	return Game.active_state.next_entity_id

func set_entity_active(handle: int, active: bool = true):
	if active == true and !active_entities.has(handle):
		active_entities.append(handle)
		return
	if active == false and active_entities.has(handle):
		active_entities.erase(handle)
		return

func init_entity_behaviour(handle: int): 
	var ent: GameEntityData = entities.get(handle)
	if ent == null: return
	
	var behv: GameEntityBehaviour = Database.get_ent_cfg(ent.type).entity_behaviour
	if behv and behv is GameEntityBehaviour:
		behv.init_behv(ent)

func get_ent_behaviour(handle: int) -> GameEntityBehaviour:
	var ent: GameEntityData = entities.get(handle)
	if ent != null:
		var behv: GameEntityBehaviour = Database.get_ent_cfg(ent.type).entity_behaviour
		if behv and behv is GameEntityBehaviour:
			return behv
	return null

func reload_entity_visual(handle: int):
	var ent: GameEntityData = entities.get(handle)
	if ent == null: return
	
	var old_visual: Node = entitys_visualized.get(handle)
	if old_visual != null:
		entitys_visualized.erase(handle)
		old_visual.queue_free()
	
	var new_visual: PackedScene = Database.get_ent_cfg(ent.type).entity_visual_scene
	if new_visual != null and new_visual is PackedScene and new_visual.can_instantiate():
		var new_v_node := new_visual.instantiate()
		if ent.state.get("ent:background") == true:
			background_entity_visual_container.add_child(new_v_node)
		else:
			foreground_entity_visual_container.add_child(new_v_node)
		
		if new_v_node is Node2D:
			var cell := ent.cell_position
			new_v_node.global_position = Vector2(int(cell.x * Game.GRID_SIZE), int(cell.y * Game.GRID_SIZE))
		
		entitys_visualized.set(handle, new_v_node)

func set_handle_cell(handle: int, cell: Vector2i = Vector2i.ZERO):
	if entity_by_cell.get(cell):
		entity_by_cell.erase(cell)
	entity_by_cell.set(cell, handle)

func set_ent_origin(handle: int, origin: Vector2i = Vector2i.ZERO):
	var ent: GameEntityData = entities[handle]
	if ent == null: return
	var ent_d = Database.get_ent_cfg(ent.type)
	remove_handle_occupied_cells(handle)
	var visual_node: Node2D = entitys_visualized.get(handle)
	ent.cell_position = origin
	if visual_node != null and visual_node is Node2D:
		var cell := Vector2(int(origin.x * Game.GRID_SIZE), int(origin.y * Game.GRID_SIZE))
		visual_node.global_position = cell
	for offset in ent_d.occupy_tile_offsets:
		var world = origin + offset
		entity_by_cell.set(world, handle)

func remove_handle_occupied_cells(handle: int):
	for cell in entity_by_cell:
		var c_handle = entity_by_cell.get(cell, 0)
		if c_handle == handle:
			remove_handle_cell(cell)

func remove_handle_cell(cell: Vector2i):
	if entity_by_cell.get(cell):
		entity_by_cell.erase(cell)

func set_entity_cell(handle: int, pos: Vector2i = Vector2i.ZERO):
	var ent: GameEntityData = entities.get(handle)
	if ent != null:
		var visual_node: Node2D = entitys_visualized.get(handle)
		if visual_node != null and visual_node is Node2D:
			var cell := Vector2(int(pos.x * Game.GRID_SIZE), int(pos.y * Game.GRID_SIZE))
			if !ent.temporary: set_handle_cell(handle, cell)
			ent.cell_position = cell
			visual_node.global_position = cell

func remove_entity_visual(handle: int):
	var visual: Node = entitys_visualized.get(handle)
	if visual != null:
		entitys_visualized.erase(handle)
		visual.queue_free()

func remove_entity(handle: int):
	var ent: GameEntityData = entities.get(handle)
	if ent != null:
		if disable_entity_occupy_multiple_cells:
			remove_handle_cell(ent.cell_position)
		else:
			remove_handle_occupied_cells(handle)
		remove_entity_visual(handle)
		entities.erase(handle)

func create_entity(type: GameEnum.Entity, position: Vector2i = Vector2i.ZERO, temp: bool = false, disable_behv: bool = false) -> int:
	var id = next_id()
	var data = GameEntityData.new()
	
	data.type = type
	data.handle = id
	data.cell_position = position
	data.temporary = temp
	#data.visual_id = visual
	
	entities.set(id, data)
	reload_entity_visual(id)
	
	if !disable_behv: init_entity_behaviour(id)
	if !data.temporary: 
		if disable_entity_occupy_multiple_cells:
			set_handle_cell(id, position) 
		else:
			set_ent_origin(id, position)
	
	return id

func get_entity_visual(handle: int) -> Node:
	return entitys_visualized.get(handle)

func get_entity(handle: int) -> GameEntityData:
	return entities.get(handle)

func get_entity_at_cell(cell: Vector2i) -> int:
	return entity_by_cell.get(cell, -1)

#NOTE: unoptmized
func get_entities_of_type(type: GameEnum.Entity) -> Array[int]:
	var result: Array[int] = []
	for handle in entities:
		var ent := entities[handle]
		if ent.type == type:
			result.append(handle)
	return result

func _process(delta: float) -> void:
	if active_entities.size() > 0:
		for handle in active_entities:
			var ent := get_entity(handle)
			var behv := get_ent_behaviour(handle)
			behv.process_behv(ent, delta)

func _ready():
	if Game.game_manager == null:
		await Game.game_manager_ready
	
	for handle in entities:
		var ent: GameEntityData = entities[handle]
		if !ent.temporary:
			if disable_entity_occupy_multiple_cells:
				set_handle_cell(handle, ent.cell_position)
			else:
				set_ent_origin(handle, ent.cell_position)
		reload_entity_visual(handle)
		init_entity_behaviour(handle)
