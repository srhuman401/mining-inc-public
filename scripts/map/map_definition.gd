class_name MapState extends Resource

@export var tile_map: Dictionary = {}
@export var lighting_map: Dictionary[Vector2i, int]
@export var entity_map: Dictionary[int, GameEntityData] = {}

@export var from_tile_map: PackedScene:
	set(value):
			from_tile_map = value
			if from_tile_map != null:
				_try_build_from_tilemap()
@export var center_position: Vector2

func _try_build_from_tilemap() -> void:
	var trees := 1000
	if from_tile_map != null:
		var loadmap := from_tile_map.instantiate()
	
		if loadmap is GameMapScene:
			var added_spawn_location_already = false
			
			var game_tiles: TileMapLayer = loadmap.game_tile_map
			var lighting_tiles: TileMapLayer = loadmap.lighting_tile_map
			assert(game_tiles, "GameMapScene 'game_tile_map' is null. Path: " + from_tile_map.resource_path)
			
			for cell in game_tiles.get_used_cells():
				var tile_id = game_tiles.get_cell_source_id(cell)
				
				if tile_id == GameEnum.TileType.MARKER_SPAWN_LOC and !added_spawn_location_already:
					print('added spawn at ' ,cell)
					added_spawn_location_already = true
					center_position = Vector2(cell.x, cell.y)
					print(center_position)
					continue
				
				if tile_id == GameEnum.TileType.MARKER_TREE:
					#print("Adding tree... yo")
					trees +=1
					var entity = GameEntityData.new()
					
					entity.handle = trees
					entity.cell_position = cell
					entity.type = GameEnum.Entity.TREE
					entity_map.set(trees, entity)
					
					continue
				
				var data: GameTileData = GameTileData.new()
				data.position = cell
				data.type = tile_id
				data.texture_id = tile_id
				#if randi_range(1,2) == 1:
				#	data.hidden = true
				tile_map[cell] = data
			
			if lighting_tiles: 
				#print("-- has lighting tiles")
				for cell in lighting_tiles.get_used_cells():
					#print('-- setting cell: ',cell)
					var tile_id = lighting_tiles.get_cell_source_id(cell)
					if tile_id != -1:
						#print("-- set cell: ",cell," to ",tile_id)
						lighting_map.set(cell, tile_id)
						#print("----")
				
			print("Loaded MapState FROM TILE MAP RESOURCE_PATH,SELF RESOURCE PATH: ", from_tile_map.resource_path, ","+resource_path)
			from_tile_map = null
			loadmap.queue_free()
