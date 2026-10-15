class_name EntityTreeBehv
extends GameEntityBehaviour

const DEFAULT_HEALTH: int = 100
const REGEN_TIME_MIN = 10
const REGEN_TIME_MAX = 35

const FLIPPED = "tree:flipped"
const REGEN_TIME = "tree:regen_time_left"
const TREE_HEALTH = "tree:health"

func get_regen_time(ent: GameEntityData) -> float:
	return ent.state.get(REGEN_TIME, 0.0)

func get_health(ent: GameEntityData) -> int:
	return ent.state.get(TREE_HEALTH, DEFAULT_HEALTH)

func set_health(ent: GameEntityData, amount: int):
	ent.state.set(TREE_HEALTH, amount)

func get_ent_sprite(ent: GameEntityData) -> AnimatedSprite2D:
	return Game.game_manager.entity.get_entity_visual(ent.handle)

func refresh_sprite(ent: GameEntityData):
	var regen_time := get_regen_time(ent)
	var sprite = get_ent_sprite(ent)
	assert(sprite)
	
	if regen_time > 0.0:
		sprite.frame = 1
	else:
		sprite.frame = 0

func take_damage(ent: GameEntityData, amount: int) -> bool:
	if get_regen_time(ent) > 0.0: return false
	if get_health(ent) <= 0: return false
	
	var health = get_health(ent)
	health -= amount
	if health <= 0:
		set_health(ent, 0)
		ent.state.set(REGEN_TIME, randi_range(REGEN_TIME_MIN, REGEN_TIME_MAX))
		refresh_sprite(ent)
		return true
	
	set_health(ent, health)
	return true

func _on_init(ent: GameEntityData):
	if ent.state.get("ent:background") != true:
		ent.state.set("ent:background", true)
		Game.game_manager.entity.reload_entity_visual(ent.handle)
	
	if ent.state.get(FLIPPED) == null:
		ent.state.set(FLIPPED, randi_range(0,1) == 1)
	
	var my_sprite: AnimatedSprite2D = get_ent_sprite(ent)
	if my_sprite != null and my_sprite is AnimatedSprite2D:
		my_sprite.flip_h = ent.state.get(FLIPPED, false)

func _on_process(ent: GameEntityData, delta: float):
	var time := get_regen_time(ent)
	if time > 0.0:
		time -= delta
		ent.state.set(REGEN_TIME, time)
		if time <= 0.0:
			refresh_sprite(ent)
			set_health(ent, DEFAULT_HEALTH)

func _on_tick(_ent: GameEntityData, _time: float):
	pass

func _on_remove(_ent: GameEntityData):
	pass
