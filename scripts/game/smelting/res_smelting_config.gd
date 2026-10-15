class_name SmeltingConfig
extends Resource

@export var config: Dictionary[GameEnum.ResourceType, GameEnum.ResourceType] = {}
@export var smelt_time: float = 5.0
@export var fuel_config: Dictionary[GameEnum.ResourceType, int] = {}
