@abstract class_name OreTileBehaviour extends GameTileBehaviour

enum OreState
{
	IDLE,
	EMPTY,
}

const HP_ORE = "ore:hp_ore"
const STATE_ORE = "ore:state"
const REGEN_TIME_STAMP = "ore:regen_timestamp"
const BREAKING_EXPIRE_TIMESTAMP = "ore:stopbreaking_timestamp"

@abstract func get_max_health(tile: GameTileData) -> int
func on_broken(_tile: GameTileData): pass
func on_repaired(_tile: GameTileData): pass
@abstract func get_regenerate_time(tile: GameTileData) -> float

func _is_breaking(tile: GameTileData, current_time: float) -> bool:
	return current_time < tile.state.get(
		BREAKING_EXPIRE_TIMESTAMP,
		current_time
		)

func _get_state(tile: GameTileData) -> OreState:
	return tile.state.get(STATE_ORE, OreState.IDLE)

func _on_initialize(tile: GameTileData):
	var state := tile.state
	if state.get(HP_ORE) ==null:
		state.set(HP_ORE, get_max_health(tile)) 
	if state.get(STATE_ORE) ==null:
		state.set(STATE_ORE, OreState.IDLE)
	if state.get(STATE_ORE) ==OreState.EMPTY:
		print("[ore behv] Restoring empty state and marking tile as active")
		Game.game_manager.mark_tile_as_active(tile)

func _on_tick(tile: GameTileData, current_time: float):
	var state := _get_state(tile)
	var vfx_mgr := Game.game_manager.vfx_manager
	#print(state)
	if state == OreState.EMPTY:
		#print("Is empty")
		tile.state.set(BREAKING_EXPIRE_TIMESTAMP, 0.0)
		if current_time >= tile.state.get(REGEN_TIME_STAMP, current_time):
			print("[ore behv] Ready to repair")
			Game.game_manager.remove_active_tile(tile)
			tile.state.set(REGEN_TIME_STAMP, null)
			tile.state.set(HP_ORE, get_max_health(tile))
			tile.state.set(STATE_ORE, OreState.IDLE)
			on_repaired(tile)
	if _is_breaking(tile, current_time):
		print("is breaking")
		if vfx_mgr.get_vfx_at_tile(tile.position) == null:
			vfx_mgr.create_vfx_at_tile(tile.position, "orebreaking")
	else:
		print("not breaking")
		if vfx_mgr.get_vfx_at_tile(tile.position) != null:
			vfx_mgr.remove_vfx(tile.position)

func damage(tile: GameTileData, amount: int = 1) -> bool:
	if _get_state(tile) != OreState.IDLE: return false
	#print("attack worked")
	var current_health: int = tile.state.get(HP_ORE,99)
	current_health -= amount
	tile.state.set(HP_ORE, current_health)
	
	tile.state.set(BREAKING_EXPIRE_TIMESTAMP, 
	Game.active_state.game_time + 0.75)
	
	if current_health <= 0:
		tile.state.set(STATE_ORE, OreState.EMPTY)
		tile.state.set(REGEN_TIME_STAMP, Game.active_state.game_time + get_regenerate_time(tile))
		tile.texture_id = TextureId.ORE_EMP_TIL
		Game.game_manager.mark_tile_as_dirty(tile.position)
		Game.game_manager.refresh_tiles()
		Game.game_manager.mark_tile_as_active(tile)
		Game.game_manager.play_world_sound_at_pos(
			Sounds.STONE_BREAK,
			Game.game_manager.get_cell_world_pos(tile.position)
		)
		on_broken(tile)
	return true
