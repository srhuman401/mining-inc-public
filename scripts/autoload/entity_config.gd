class_name GameEntityConfig extends Node

const PLACEHOLDER = preload("uid://dsnkx5gvgd17g")

static var map_behaviours: Dictionary = {
	GameEnum.Entity.DRILL_T0: Tier0DrillEntityBehv.new(),
	GameEnum.Entity.DRILL_T1: Tier1DrillEntityBehv.new(),
	GameEnum.Entity.DRILL_T2: Tier2DrillEntityBehv.new(),
	GameEnum.Entity.DRILL_DOUBLE: DoubleDrillEntityBehv.new(),
	
	GameEnum.Entity.TREE: EntityTreeBehv.new(),
}

static var map_visuals: Dictionary[GameEnum.Entity, PackedScene] = {
	GameEnum.Entity.TEST_ENT: PLACEHOLDER, # Ent PlaceHolder Visual
	
	# drills
	GameEnum.Entity.DRILL_T0: load("res://scenes/entity/ent_drl_t0_visual.tscn"),
	GameEnum.Entity.DRILL_T1: load("res://scenes/entity/ent_drl_t1_visual.tscn"),
	GameEnum.Entity.DRILL_T2: load("res://scenes/entity/ent_drl_t2_visual.tscn"),
	GameEnum.Entity.DRILL_DOUBLE: load("res://scenes/entity/ent_drl_dbl_visual.tscn"),
	
	# visualonly / internal
	GameEnum.Entity.CO_BASE: load("res://scenes/entity/ent_companybase_visual.tscn"),
	
	# buildings
	GameEnum.Entity.SELL_STATION: load("res://scenes/entity/ent_sell_station_visual.tscn"),
	GameEnum.Entity.FURNACE_1: load("res://scenes/entity/ent_furnace_visual.tscn"),
	GameEnum.Entity.RESEARCH_STATION: load("res://scenes/entity/ent_furnace_visual.tscn"),
	
	# misc
	GameEnum.Entity.TREE: preload("res://scenes/entity/ent_tree_visual.tscn"),
}
