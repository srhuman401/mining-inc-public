extends Control

@export var tooltip: Control
@export var name_label: Label
@export var damage_label: Label
@export var pickaxe_texture: TextureRect

func update_display():
	var pickaxe_type := Game.active_state.pickaxe_type
	var pickaxe_damage: int = Game.CONFIG.PICKAXE_STATS.get(
		pickaxe_type,
		1
	)
	
	var pickaxe_display_name = GameUtility.get_enum_name(
		GameEnum.PickaxeType,
		pickaxe_type
	)
	
	name_label.text = pickaxe_display_name + " PICKAXE"
	damage_label.text = str(pickaxe_damage) + " DAMAGE"

func set_tooltip_visible(be_visible: bool):
	tooltip.visible = be_visible

func _on_self_mouse_entered():
	set_tooltip_visible(true)

func _on_self_mouse_exited():
	set_tooltip_visible(false)

func _ready():
	var game_manager: GameManager = Game.game_manager
	if !game_manager:
		await Game.game_manager_ready
		game_manager = Game.game_manager
	
	set_tooltip_visible(false)
	game_manager.game_events.level_changed.connect(update_display)
	update_display()
	
	mouse_entered.connect(_on_self_mouse_entered)
	mouse_exited.connect(_on_self_mouse_exited)
