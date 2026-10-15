class_name CoalOreTileBehv extends OreTileBehaviour

func get_max_health(_tile: GameTileData) -> int:
	return 30

func get_regenerate_time(_tile: GameTileData) -> float:
	return 0.65

func on_repaired(tile: GameTileData):
	tile.texture_id = TextureId.ORE_COL_TIL
	Game.game_manager.mark_tile_as_dirty(tile.position)
	Game.game_manager.refresh_tiles()

func on_broken(_tile: GameTileData):
	var res_amount = randi_range(5, 8)
	Game.game_manager.resources.adj_resource(
		GameEnum.ResourceType.COAL_RAW,
		res_amount
	)
