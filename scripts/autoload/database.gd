class_name GameDatabase extends Node

const DATABASE_CONFIG: DatabaseConfiguration = preload("res://data/database_conf.tres")

var has_loaded: bool = false
var items: Dictionary[String, GameItemInfo] = {}
var resource_datas: Dictionary[GameEnum.ResourceType, GameResourceData]
var entity_config: Dictionary[GameEnum.Entity, EntityDataConfig]

signal database_loaded

func init_db():
	await load_resource_datas()
	await load_items()
	await load_entity_configs()
	
	has_loaded = true
	database_loaded.emit()

func _ready():
	init_db()

func load_items():
	print("[DB] Reload Items...")
	var base_path = DATABASE_CONFIG.items_folder
	var contents = ResourceLoader.list_directory(base_path)
	
	for filepath in contents:
		if filepath.ends_with(".tres"):
			var p_item = load(base_path + "/"+ filepath)
			if p_item is GameItemInfo:
				var item_id = filepath.get_file().get_basename()
				print("[DB] Load item, ", item_id, " Loaded and Registered!")
				items.set(item_id, p_item)
	print("[DB] FINISHED LOADING ITEMS !!!")

func load_entity_configs():
	var base_path = DATABASE_CONFIG.entity_configs_folder
	var contents = ResourceLoader.list_directory(base_path)
	
	for filepath in contents:
		if filepath.ends_with(".tres"):
			var cfg = load(base_path + "/"+ filepath)
			if cfg is EntityDataConfig:
				var eenum: GameEnum.Entity = cfg.attach_entity_enum
				print("[DB] Entity CFG, loading Entity ", GameUtility.get_enum_name(GameEnum.Entity, eenum))
				if cfg.entity_behaviour_path != "none":
					print(" - behaviour set is: ", cfg.entity_behaviour_path)
					var full_behv_path: String = DATABASE_CONFIG.entity_behv_folder + cfg.entity_behaviour_path 
					var behvload = load(full_behv_path)
					print ("  -- print behvload: ", behvload)
					if behvload && behvload is GDScript:
						var instant = behvload.new()
						if instant is GameEntityBehaviour:
							cfg.entity_behaviour = instant
							print("  -- loaded behaviour successfully")
					else:
						print("  -- failed to load behaviour!")
				else:
					print(" - has no behaviour set")
				if cfg.entity_visual_scene != null:
					print(" - has visual scene: ", cfg.entity_visual_scene.resource_path)
				else:
					print(" - no visual scene set")
				
				entity_config.set(eenum, cfg)
				print("----------------------------")

func load_resource_datas():
	var base_path = DATABASE_CONFIG.resource_data_folder
	var contents = ResourceLoader.list_directory(base_path)
	
	for folder_name in contents:
		if folder_name.begins_with("_"): continue
		var attach_path = base_path.path_join(folder_name).path_join("attach.tres")
		if ResourceLoader.exists(attach_path):
			var attach_file = load(attach_path)
			if attach_file is GameResourceAttacher:
				var r_data = GameResourceData.from_definition(attach_file)
				resource_datas.set(attach_file.for_resource_enum, r_data)

func get_item(id: String) -> GameItemInfo:
	return items.get(id)

func get_res_d(resource: GameEnum.ResourceType) -> GameResourceData:
	if !resource_datas.has(resource):
		resource_datas.set(resource, GameResourceData.empty())
	return resource_datas.get(resource)

func get_ent_cfg(resource: GameEnum.Entity) -> EntityDataConfig:
	if entity_config.has(resource):
		return entity_config.get(resource)
	return EntityDataConfig.empty()
