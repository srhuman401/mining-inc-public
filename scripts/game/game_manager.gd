class_name GameManager extends Node2D

class ActiveCheats: 
	var ignore_placement_requirements: bool = false
	var ignore_upgrade_requirements: bool = false

@export var tile_map: TileMapLayer
@export var lighting_tile_map: TileMapLayer

@export var resources: Resources
@export var fog_rect: FogOfWarRect
@export var entity: EntityManager
@export var sell_mgr: GameSellManager
@export var game_events: GameEvents
@export var vfx_manager: GameVfxManager
@export var game_camera: Camera2D
@export var upgrade_manager: GameUpgradeManager
@export var research_manager: GameResearchManager
@export var placement: PlacementManager
@export var smelting: GameSmeltingManager
@export var game_ui: GameUI

var dirty_tiles: Array[Vector2i] = []
var tile_behaviours: Dictionary[GameTileBehaviour, GameTileBehaviour] = {}
var active_tiles: Array[Vector2i] = []
var center_pos: Vector2 = Vector2.ZERO
var company_base_handle: int = -1

var active_cheats: ActiveCheats = ActiveCheats.new()

var behv_map = {
	0: CoalOreTileBehv.new(),
	1: BronzeOreTileBehv.new(),
	2: IronOreTileBehv.new(),
	3: GoldOreTileBehv.new(),
}

const TILE_SIZE = 32

signal time_changed

func _ready() -> void:
	Game.game_manager = self
	
	refresh_tiles(true)
	init_lighting_tiles()
	reload_tile_behaviours()
	
	var game_state: GameState = Game.active_state
	
	var pos_center = game_state.map_state.center_position
	if pos_center != null:
		print("detected center: ",pos_center)
		center_pos = pos_center
	
	fog_rect.world_center = center_pos
	
	company_base_handle = entity.create_entity(
		GameEnum.Entity.CO_BASE,
		pos_center,
		true
	)
	
	var test_entitys: bool = true
	if test_entitys:
		var _tree = entity.create_entity(
			GameEnum.Entity.TREE,
			Vector2i(pos_center + Vector2(3, 0)),
			true
		)
	
	$TileTick.connect("timeout", _on_tile_timer_tick)
	$ClockTick.connect("timeout", _on_clock_tick)
	$Autosave.connect("timeout", _on_autosave_timeout)
	$GameEvents.connect("level_changed", _on_level_changed)
	
	_on_level_changed()
	Game.game_manager_ready.emit()

func _on_level_changed():
	var game_state := Game.active_state
	set_fog_size(Vector2(game_state.area_width, game_state.area_height))

func _on_autosave_timeout():
	Game.try_save_active_game()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		Game.try_save_active_game()

func _on_tile_timer_tick():
	var map = Game.active_state.map_state
	for cell in active_tiles:
		var tile: GameTileData = map.tile_map[cell]
		var behv: GameTileBehaviour = get_tile_behaviour(tile)
		if behv != null:
			#print(Game.active_state.game_time)
			behv.tick_behv(tile, Game.active_state.game_time)

func _on_clock_tick():
	#print('clock ticked')
	if Game.active_state == null: return
	Game.active_state.game_time += .5
	#print(Game.active_state.game_time)
	time_changed.emit()

func _process(_delta: float) -> void:
	pass

func init_lighting_tiles():
	var map_state := Game.active_state.map_state
	var lighting = map_state.lighting_map
	
	if lighting:
		for cell in lighting:
			var id = lighting[cell]
			lighting_tile_map.set_cell(cell, id, Vector2i.ZERO)

func get_cell_world_pos(cell: Vector2i) -> Vector2:
	return Vector2(int(cell.x * Game.GRID_SIZE), int(cell.y * Game.GRID_SIZE))

func play_world_sound_at_pos(sound: AudioStream, pos: Vector2):
	var zoom = game_camera.zoom
	var distance_1 = (pos - game_camera.global_position) / zoom
	var distance = distance_1.length()
	var volume = clamp(1.0 - distance / (500.0/zoom.x), 0, 1)
	if volume < 0.1: return
	
	SoundManager.play_sound_with_pitch(sound, 
	randf_range(0.8,1.1)).volume_db = volume

func set_fog_size(rect_size: Vector2):
	var grid_size := float(Game.GRID_SIZE)
	rect_size.x = round(rect_size.x / grid_size) * grid_size
	rect_size.y = round(rect_size.y / grid_size) * grid_size
	fog_rect.rect_size = rect_size

func refresh_fog_size():
	set_fog_size(Vector2(Game.active_state.area_width, Game.active_state.area_height))

func mark_tile_as_dirty(tile: Vector2i):
	if not dirty_tiles.has(tile):
		dirty_tiles.append(tile)

func mark_tile_as_active(tile: GameTileData):
	if not active_tiles.has(tile.position):
		active_tiles.append(tile.position)

func remove_active_tile(tile: GameTileData):
	if active_tiles.has(tile.position):
		active_tiles.erase(tile.position)

func init_behaviour_on_tile(tile: GameTileData):
	var behaviour := get_tile_behaviour(tile)
	if behaviour:
		behaviour.init_behv(tile)

func get_tile_behaviour(tile: GameTileData) -> GameTileBehaviour:
	var id: int = GameConfig.TILE_BEHAVIOUR_MAP.get(tile.type, -1)
	var behaviour: GameTileBehaviour = behv_map.get(id)
	if behaviour and behaviour is GameTileBehaviour:
		return behaviour
	return null

func reload_tile_behaviours():
	var map := Game.active_state.map_state.tile_map
	for cell in map:
		init_behaviour_on_tile(map[cell])

func refresh_tiles(forced: bool = false):
	var active_game_state: GameState = Game.active_state
	if not active_game_state:
		return
		
	var map: MapState = active_game_state.map_state
	
	if forced:
		for cell in map.tile_map:
			mark_tile_as_dirty(cell)
	
	for cell in dirty_tiles:
		if not map.tile_map.has(cell):
			continue
		
		var tile_data: GameTileData = map.tile_map[cell]
		var tile_type := tile_data.texture_id
		var visual_id = tile_type as int
		
		if visual_id == GameEnum.TileType.EMPTY:
			visual_id = TextureId.INVISIBLE_TIL
		
		if tile_data.hidden == true:
			visual_id = TextureId.BLACK_TIL
			
		tile_map.set_cell(cell, visual_id, Vector2i.ZERO)
	dirty_tiles.clear()
