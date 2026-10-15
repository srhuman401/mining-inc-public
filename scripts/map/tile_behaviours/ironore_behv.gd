class_name IronOreTileBehv extends OreTileBehaviour

func get_max_health(_tile: GameTileData) -> int:
	return 23

func get_regenerate_time(_tile: GameTileData) -> float:
	return 4

func on_repaired(tile: GameTileData):
	tile.texture_id = TextureId.ORE_IRN_TIL
	Game.game_manager.mark_tile_as_dirty(tile.position)
	Game.game_manager.refresh_tiles()

func on_broken(_tile: GameTileData):
	var res_amount = randi_range(7, 9)
	Game.game_manager.resources.adj_resource(
		GameEnum.ResourceType.IRON_ORE,
		res_amount
	)
