@abstract
class_name ClickableEntityBehv
extends GameEntityBehaviour

func _on_init(ent: GameEntityData):
	pass

func _on_tick(ent: GameEntityData, time: float):
	pass

func _on_process(ent: GameEntityData, delta: float):
	pass

func _on_remove(ent: GameEntityData):
	pass

func entity_clicked():
	_on_clicked()

@abstract func _on_clicked()
