class_name DLCManifest
extends RefCounted

@export var dlc_version: String = "0.0.0"
@export var dlc_author: String = "[No author set!]"
@export var dlc_load_order: int = 0
@export var dlc_pack_name: String = "content.pck"
@export var dlc_id: String = "dlc_winter"
@export var dlc_name: String = "Unnamed DLC"

static func from_dict(dict: Dictionary) -> DLCManifest:
	var instance = DLCManifest.new()
	
	if dict.has("Version"):
		instance.dlc_version = dict.get("Version")
	
	if dict.has("Author"):
		instance.dlc_author = dict.get("Author")
	
	if dict.has("LoadOrder"):
		instance.dlc_load_order = dict.get("LoadOrder")
	
	if dict.has("DisplayName"):
		instance.dlc_name = dict.get("DisplayName")
	
	if dict.has("DLC_Id"):
		instance.dlc_id = dict.get("DLC_Id")
		
	if dict.has("ContentPackFile"):
		instance.dlc_pack_name = dict.get("ContentPackFile")
	
	return instance
