class_name BronzeOreTileBehv extends OreTileBehaviour

func get_max_health(_tile: GameTileData) -> int:
	return 12

func get_regenerate_time(_tile: GameTileData) -> float:
	return 2.3

func on_repaired(tile: GameTileData):
	tile.texture_id = TextureId.ORE_BRZ_TIL
	Game.game_manager.mark_tile_as_dirty(tile.position)
	Game.game_manager.refresh_tiles()

func on_broken(_tile: GameTileData):
	var res_amount = randi_range(7, 9)
	Game.game_manager.resources.adj_resource(
		GameEnum.ResourceType.BRONZE_ORE,
		res_amount
	)
