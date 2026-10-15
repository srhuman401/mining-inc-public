class_name TileUtility extends Node

static func is_tile_air(tile: GameTileData):
	return tile == null or tile.type == GameEnum.TileType.FOREGROUND_STONE

static func get_below_cell(cell: Vector2i) -> Vector2i:
	return cell + Vector2i(0 ,1)

static func get_above_cell(cell: Vector2i) -> Vector2i:
	return cell - Vector2i(0, 1)
