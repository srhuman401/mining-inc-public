class_name GameVfxManager
extends Node

var cell_to_vfx: Dictionary[Vector2i, Node2D] = {}
const vfx_scene_mapping := {
	"orebreaking": preload("res://scenes/vfx/vfx_oremining.tscn"),
}

func get_vfx_at_tile(cell: Vector2i) -> Node2D:
	if cell_to_vfx.has(cell):
		return cell_to_vfx.get(cell)
	return null

func remove_vfx(cell :Vector2i):
	var vfx_node: Node2D = cell_to_vfx.get(cell)
	if vfx_node != null:
			vfx_node.queue_free()
			cell_to_vfx.erase(cell)

func get_cell_to_world(cell: Vector2i) -> Vector2:
	var cell_pos := Vector2(int(cell.x * Game.GRID_SIZE), int(cell.y * Game.GRID_SIZE))
	return cell_pos

func create_vfx_at_tile(cell: Vector2i, vfx: String):
		if cell_to_vfx.get(cell) != null:
			remove_vfx(cell)
		
		var scene_packed: PackedScene = vfx_scene_mapping.get(vfx)
		if scene_packed != null && scene_packed is PackedScene:
			var vfx_node2d: Node2D = scene_packed.instantiate()
			var w_pos = get_cell_to_world(cell)
			
			add_child(vfx_node2d)
			vfx_node2d.global_position = w_pos
			cell_to_vfx.set(cell, vfx_node2d)
