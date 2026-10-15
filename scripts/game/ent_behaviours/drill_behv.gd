@abstract class_name DrillEntityBehaviour extends GameEntityBehaviour

const DRILL_COUNTDOWN = "drill:countdown"
#const DRILL_LASTDAMAGETIMER = "drill:lastdamagetimer"

func _on_init(ent: GameEntityData):
	var ent_manager := Game.game_manager.entity
	ent_manager.set_entity_active(ent.handle)
	
	var visual: AnimatedSprite2D = ent_manager.get_entity_visual(ent.handle)
	if visual and visual is AnimatedSprite2D:
		visual.offset = Vector2(visual.offset.x, -16.0)
		visual.play(&"default")

func _on_tick(_ent: GameEntityData, _time: float):
	pass

func _on_process(ent: GameEntityData, delta: float):
	if Game.active_state == null: return
	var countdown: float = ent.state.get(DRILL_COUNTDOWN, -1)
	if countdown == -1:
		countdown = get_rate(ent)
		#ent.state.set(DRILL_COUNTDOWN, countdown)
	
	countdown -= delta
	if countdown <= 0:
		ent.state.set(DRILL_COUNTDOWN, get_rate(ent))
		var damage := get_damage(ent)
		var tile_below: GameTileData = Game.active_state.map_state.tile_map.get(ent.cell_position)
		
		if tile_below != null:
			var behv: OreTileBehaviour = Game.game_manager.get_tile_behaviour(tile_below)
			
			if behv != null and behv is OreTileBehaviour:
				behv.damage(tile_below, damage)
	else:
		ent.state.set(DRILL_COUNTDOWN, countdown)

func _on_remove(ent: GameEntityData):
	Game.game_manager.entity.set_entity_active(ent.handle, false)

func get_rate(_ent: GameEntityData) -> float: return 1
func get_damage(_ent: GameEntityData) -> int: return 1
