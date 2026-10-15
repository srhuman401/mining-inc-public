extends Node

func _ready():
	print("INIT start")
	
	var steamSuccess = Steam.steamInit()
	print("[STEAM] Initialize Success:", steamSuccess)
	
	if not Steam.isSteamRunning():
		print("[STEAM] Steam not running")
	
	print("INIT done")
	
	# Continue 
	get_tree().change_scene_to_file.call_deferred(ScenePaths.INTRO)
