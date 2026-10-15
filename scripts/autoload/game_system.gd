extends Node

const MAX_GAME_SLOTS = 3
var CONFIG: GameConfig
const GRID_SIZE := 32
const meta_extension = ".meta"
const SAVE_DIRECTORY = "user://"

# configurations
var smelting_config: SmeltingConfig
var research_config: ResearchConfig
var play_config: PlayConfiguration

var active_slot: int
var active_state: GameState
var active_meta: GameMetaData
var game_manager: GameManager

var loading: bool = false
var loading_path: String = ""

var cur_requested_slot: int = -1
var cur_requested_path: String = ""
var cur_requesting: bool = false
var cur_request_callback: Callable = Callable()

var already_shown_intro: bool = false

signal game_manager_ready

func _ready():
	CONFIG = load("res://data/game_config_00.tres")
	smelting_config = load("res://data/smelting_conf.tres")
	research_config = load("res://data/research_conf.tres")
	play_config = load("res://data/play_conf.tres")

func time() -> float:
	return Time.get_ticks_msec() / 1000.0

func ingame_time() -> float:
	if !active_state: return 0.0
	return active_state.game_time

func is_active_game() -> bool:
	return active_slot != -1 and active_state != null

func _save_slot_content(slot: int, slot_content: GameState):
	ResourceSaver.save(slot_content, get_slot_path(slot))

func _save_meta_data(slot: int, content: GameMetaData):
	ResourceSaver.save(content, get_meta_path(slot))

func new_game_slot(slot: int, _option: int = -1):
	var def: MapState = play_config.main_map
	var game_state: GameState = GameState.new()
	var meta: GameMetaData = GameMetaData.new()
	
	var new_map_state = MapState.new()
	game_state.map_state = new_map_state #def.duplicate(true) as MapState
	#print(def.tile_map)
	
	var fresh_dict := {}
	var fresh_lightingdict: Dictionary[Vector2i, int] = {}
	var fresh_entdict: Dictionary[int, GameEntityData] = {}
	for key in def.tile_map:
		fresh_dict[key] = def.tile_map[key].duplicate(true)
	
	for key in def.lighting_map:
		fresh_lightingdict[key] = def.lighting_map[key]
	
	for handle in def.entity_map:
		fresh_entdict[handle] = def.entity_map[handle].duplicate(true)
	#print(fresh_dict)
	
	new_map_state.entity_map = fresh_entdict
	new_map_state.tile_map = fresh_dict
	new_map_state.lighting_map = fresh_lightingdict
	new_map_state.center_position = def.center_position
	
	_save_slot_content(slot, game_state)
	_save_meta_data(slot, meta)
	#ResourceSaver.save(game_state, CONFIG.save_game_path + str(slot) + CONFIG.save_extension)

func get_slot_path(slot: int) -> String:
	return SAVE_DIRECTORY + play_config.save_prefix + CONFIG.save_game_path + str(slot) + CONFIG.save_extension

func get_meta_path(slot: int) -> String:
	return SAVE_DIRECTORY + play_config.save_prefix + CONFIG.save_game_path + str(slot) + meta_extension + CONFIG.meta_save_extension

func force_delete_slot(slot: int):
	var path: String = get_slot_path(slot)
	if slot_content_exists(slot):
		DirAccess.remove_absolute(path)

func request_slot_content(slot: int, callback: Callable):
	var path: String = get_slot_path(slot)
	
	if cur_requesting == true:
		push_error("[game] .request_slot_content failed, cannot request more than 1 slot at a time!")
		return
	
	if callback != null: cur_request_callback = callback
	ResourceLoader.load_threaded_request(path)
	cur_requesting = true
	cur_requested_slot = slot
	cur_requested_path = path

#DO NOT USE, blocks main thread. use .request_slot_content instead (callback API)
func get_slot_content(slot: int) -> GameState:
	var path := CONFIG.save_game_path + str(slot) + CONFIG.save_extension
	if not ResourceLoader.exists(path): return null
	var load_r: GameState = ResourceLoader.load(path)
	if load_r:
		return load_r
	return null

#NOTE: does not determine if the slot is corrupted or has data. Only if it has an existing file.
func slot_content_exists(slot: int) -> bool:
	return ResourceLoader.exists(get_slot_path(slot)) == true

func retrieve_slot_meta(slot: int) -> GameMetaData:
	var path := get_meta_path(slot)
	if ResourceLoader.exists(path):
		return ResourceLoader.load(path)
	return GameMetaData.new()

func load_game_slot(slot: int) -> void:
	var slot_state: GameState = get_slot_content(slot)
	if slot_state != null:
		active_state = slot_state
		active_slot = slot
		active_state.times_loaded += 1
		SceneLoader.enter_scene(ScenePaths.MAIN_GAME)

func enter_game_slot(state: GameState, slot: int) -> void:
	active_slot = slot
	active_state = state
	active_meta = retrieve_slot_meta(slot)
	active_state.times_loaded +=1
	SceneLoader.enter_scene(ScenePaths.MAIN_GAME)

func try_save_active_game() -> bool:
	print("[game] Trying to save")
	if active_slot != -1 and active_state != null:
		print("[game] Can save but might not work")
		active_state.save_version += 1
		var save_state := active_state.duplicate(true)
		
		var to_remove := []
		var entity_map: Dictionary[int, GameEntityData] = save_state.map_state.entity_map
		for handle in entity_map:
			var ent := entity_map[handle]
			if ent.temporary == true:
				to_remove.append(handle)
		
		for handle in to_remove:
			entity_map.erase(handle)
		
		_save_slot_content(active_slot, save_state)
		if active_meta != null:
			active_meta.company_level_integer = save_state.company_level
			_save_meta_data(active_slot, active_meta)
		
		print("[game] Save did work ")
		return true
	return false

func return_to_menu(save: bool = false):
	if save:
		try_save_active_game()
	SceneLoader.enter_scene(ScenePaths.MAIN_MENU)
	unload_active_game()

func unload_active_game():
	game_manager = null
	active_slot = -1
	active_state = null
	active_meta = null

func stop_requesting():
	cur_requested_path = ""
	cur_requested_slot = -1
	cur_requesting = false
	cur_request_callback = Callable()

func _process(_delta: float) -> void:
	if cur_requesting and cur_requested_path != "":
		var status := ResourceLoader.load_threaded_get_status(cur_requested_path)
		
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var resource = ResourceLoader.load_threaded_get(cur_requested_path)
			var cb = cur_request_callback
			if cb != null and cb is Callable and cb.is_valid():
				cb.call(true, resource, cur_requested_slot)
			
			stop_requesting()
		elif status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			var cb = cur_request_callback
			if cb != null and cb is Callable and cb.is_valid():
				cb.call(false)
			
			stop_requesting()
