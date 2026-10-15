@abstract class_name GameTileBehaviour extends RefCounted

#var behv_tile: GameTileData

func init_behv(tile: GameTileData):
	_on_initialize(tile)

func tick_behv(tile: GameTileData, current_time: float):
	_on_tick(tile, current_time)

@abstract func _on_initialize(tile: GameTileData)
@abstract func _on_tick(tile: GameTileData, current_time: float)
