class_name GameItemInfo extends Resource

## Controls how placement is validated.
enum PlacementType
{
	## Can only be placed on ores,
	DRILL, 
	## Can be placed anywhere,
	DECORATION,
	## Can only be placed above surface.
	BUILDING,
}

@export_category("Props")
@export var display_name: String = "FailedToLoad"
@export var icon_display_image: Texture
@export var hidden: bool = false
@export var entity_id: GameEnum.Entity

@export_category("Misc")
@export var placement_type: PlacementType = PlacementType.DECORATION
@export var recipe: Dictionary[GameEnum.ResourceType, int] = {}
@export var recipe_v2: GameRecipe = GameRecipe.new()

@export_category("Debug")
## The name used to get your item via commands (REQUIRED. PLEASE CHANGE THIS)
@export var debug_name: String = "CHANGE_ME"

# meta, set by external scripts / database loader
var item_id: int = -1
