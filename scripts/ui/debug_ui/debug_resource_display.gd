extends Label

@export var format_like_money: bool = false
@export var resource_to_track: GameEnum.ResourceType = GameEnum.ResourceType.CURRENCY_MONEY
@export var prefix: String = "Resource:"

func update_text():
	var amount = Game.game_manager.resources.get_resource(resource_to_track)
	text = prefix + " " + str(amount)

func _on_resources_resources_changed(changed: GameEnum.ResourceType):
	if changed == resource_to_track:
		update_text()

func _ready():
	if Game.game_manager == null:
		await Game.game_manager_ready
	
	var manager := Game.game_manager
	manager.resources.resource_changed.connect(_on_resources_resources_changed)
	update_text()
