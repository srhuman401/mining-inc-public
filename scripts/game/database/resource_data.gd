class_name GameResourceData
extends RefCounted

@export var smelting_data: GameResourceSmeltingData
@export var display_info: GameResourceDisplayInfo
@export var sell_data: GameResourceSellingData

static func from_definition(def: GameResourceAttacher) -> GameResourceData:
	var data = GameResourceData.new()
	
	if def.display_behaviour:
		data.display_info = def.display_behaviour
	else:
		data.display_info = GameResourceDisplayInfo.new()
	
	if def.smelt_behaviour:
		data.smelting_data = def.smelt_behaviour
	else:
		data.smelting_data = GameResourceSmeltingData.new()
	
	if def.sell_behaviour:
		data.sell_data = def.sell_behaviour
	else:
		data.sell_data = GameResourceSellingData.new()
	
	return data

static func empty() -> GameResourceData:
	var data = GameResourceData.new()
	data.smelting_data = GameResourceSmeltingData.new()
	data.display_info = GameResourceDisplayInfo.new()
	data.sell_data = GameResourceSellingData.new()
	return data
