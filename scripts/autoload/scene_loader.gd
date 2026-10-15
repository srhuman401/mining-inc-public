extends Node

var scene_path: String = ""

func enter_scene(scene: String):
	scene_path = scene
	get_tree().change_scene_to_file(ScenePaths.LOADING_SCREEN)
	ResourceLoader.load_threaded_request(scene_path)

func _process(_delta: float):
	if scene_path == "":
		return
	
	var status := ResourceLoader.load_threaded_get_status(scene_path)
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var new_scene := ResourceLoader.load_threaded_get(scene_path)
		get_tree().change_scene_to_packed(new_scene)
		scene_path = ""
