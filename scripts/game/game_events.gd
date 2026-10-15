class_name GameEvents extends Node

signal level_changed
signal research_level_changed
signal researching_status_changed
signal smelt_status_changed
signal smelt_queue_changed
signal sell_items_changed
signal sold_items

func emit_level_changed() -> void: 
	level_changed.emit()

func emit_smelt_status_changed() -> void:
	smelt_status_changed.emit()

func emit_smelt_queue_changed() -> void:
	smelt_queue_changed.emit()

func emit_research_level_changed() -> void:
	research_level_changed.emit()

func emit_researching_status_changed() -> void:
	researching_status_changed.emit()

func emit_sell_items_changed() -> void:
	sell_items_changed.emit()

func emit_sold_items() -> void:
	sold_items.emit()
