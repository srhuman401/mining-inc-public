class_name GameState extends Resource

@export var map_state: MapState
@export var game_time: float = 0
@export var resources_stored: Dictionary = {
	GameEnum.ResourceType.CURRENCY_MONEY: 0,
	GameEnum.ResourceType.COAL_RAW: 0,
}

@export var next_entity_id: int = 0
@export var times_loaded: int = 0
@export var save_version: int = 0
@export var done_onboarding: bool = false
@export var game_flags: Dictionary[String, bool] = {}

# progression
@export var company_level: int = 0
@export var research_level: int = 0

# stats
@export var area_width: int = 500
@export var area_height: int = 500
@export var pickaxe_type: GameEnum.PickaxeType = GameEnum.PickaxeType.MAKESHIFT

# smelting
@export var queued_smelting_rewards: Dictionary[GameEnum.ResourceType, FurnaceSmeltingResult] = {
	
}
@export var smelting_time_left: float = 0
@export var is_smelting: bool = false
@export var smelting_fuel: int = 100

# research
@export var is_researching_active: bool = false
@export var researching_time_left: float = 0

# selling
## [Resource Enum] -> Amount to sell
@export var resources_to_sell: Dictionary[GameEnum.ResourceType, int] = {}
@export var sell_multiplier: float = 1.0
