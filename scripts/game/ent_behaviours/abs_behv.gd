@abstract class_name GameEntityBehaviour extends RefCounted

var ticking: bool = false
var processing: bool = false

func init_behv(ent: GameEntityData):
	_on_init(ent)

func tick_behv(ent: GameEntityData, time: float):
	_on_tick(ent, time)

func process_behv(ent: GameEntityData, delta: float):
	_on_process(ent, delta)

func remove_ent_behv(_tile: GameEntityData):
	_on_remove(_tile)

@abstract func _on_init(ent: GameEntityData)
@abstract func _on_tick(ent: GameEntityData, time: float)
@abstract func _on_process(ent: GameEntityData, delta: float)
@abstract func _on_remove(ent: GameEntityData)
