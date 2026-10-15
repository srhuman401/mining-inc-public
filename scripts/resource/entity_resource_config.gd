class_name EntityDataConfig
extends Resource

@export var attach_entity_enum: GameEnum.Entity
@export var entity_behaviour_path: String = "entity_behv.gd"
@export var entity_visual_scene: PackedScene
@export var occupy_tile_offsets: Array[Vector2i] = [Vector2i.ZERO]

var entity_behaviour: GameEntityBehaviour

static func empty() -> EntityDataConfig:
	var cf = EntityDataConfig.new()
	cf.entity_behaviour_path = "none"
	return cf
