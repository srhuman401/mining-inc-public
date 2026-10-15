class_name GameTileData extends Resource

@export var type: GameEnum.TileType = GameEnum.TileType.EMPTY
@export var texture_id: int = TextureId.PLACEHOLDER_TIL
@export var is_resource: bool
@export var position: Vector2i
@export var state: Dictionary
@export var hidden: bool = false
