class_name GoldOreTileBehv extends OreTileBehaviour

func get_max_health(_tile: GameTileData) -> int:
	return 16

func get_regenerate_time(_tile: GameTileData) -> float:
	return 3

func on_repaired(tile: GameTileData):
	tile.texture_id = TextureId.ORE_GLD_TIL
	Game.game_manager.mark_tile_as_dirty(tile.position)
	Game.game_manager.refresh_tiles()

func on_broken(_tile: GameTileData):
	var res_amount = randi_range(2, 4)
	Game.game_manager.resources.adj_resource(
		GameEnum.ResourceType.GOLD_ORE,
		res_amount
	)
