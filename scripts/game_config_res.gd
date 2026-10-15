class_name GameConfig extends Resource
@export var island_definitions: Array[MapState] = []
@export var default_island_definition: MapState
@export var save_game_path: String = "user://_sav_"
@export var max_saves: int = 5
@export var settings_save_path: String = "user://_userconf_.cfg"
@export var save_extension: String = ".tres"
@export var meta_save_extension: String = ".res"
@export var main_game_scene: PackedScene
@export var main_menu_scene: PackedScene
@export var is_release: bool = false
@export var resource_int_cap: int = 999_999
@export var max_company_level: int = 900
@export var max_research_level: int = 900

static var TILE_BEHAVIOUR_MAP: Dictionary = {
	GameEnum.TileType.COAL_ORE: 0,
	GameEnum.TileType.BRONZE_ORE: 1,
	GameEnum.TileType.IRON_ORE: 2,
	GameEnum.TileType.GOLD_ORE: 3,
}

@export var GAME_UPGRADES: Array[GameBaseUpgrade] = []

@export var PICKAXE_STATS: Dictionary[GameEnum.PickaxeType, int] = {}
