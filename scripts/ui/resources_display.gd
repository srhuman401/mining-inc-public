extends Control

var display_map: Dictionary[GameEnum.ResourceType, ResourceNodeUI] = {}
var manager: GameManager

var show_resources := []

@export var node_scene: PackedScene
@export var vbox_cont: VBoxContainer

class ResourceDisplayForTs:
	var enum_r: GameEnum.ResourceType
	var disp_data: GameResourceDisplayInfo

func _on_resource_changed(resource: GameEnum.ResourceType):
	var disp_node: ResourceNodeUI = display_map.get(resource)
	if disp_node:
		var amount: int = manager.resources.get_resource(resource)
		disp_node.set_amount(amount)

func _ready():
	if not Game.game_manager:
		await Game.game_manager_ready
	
	manager = Game.game_manager
	if manager == null: return
	assert(node_scene)
	
	for resource in GameEnum.ResourceType.values():
		var data = GameUtility.get_resource_display_data(resource)
		var ts = ResourceDisplayForTs.new()
		ts.disp_data = data
		ts.enum_r = resource
		show_resources.append(ts)
		
	show_resources.sort_custom(func(a:ResourceDisplayForTs, b:ResourceDisplayForTs):
		return a.disp_data.list_display_order < b.disp_data.list_display_order
	)
	
	for resource_ts in show_resources:
		var resource: GameEnum.ResourceType = resource_ts.enum_r
		var displaydata: GameResourceDisplayInfo = resource_ts.disp_data
		
		if !displaydata.show_in_resource_list: continue
		
		var new_node: ResourceNodeUI = node_scene.instantiate()
		assert(new_node is ResourceNodeUI, "node_scene is not a root node of ResourceNodeUI type")
		vbox_cont.add_child(new_node)
		
		new_node.set_display_data(displaydata)
		display_map.set(resource, new_node)
		_on_resource_changed(resource) #force it to update
	
	manager.resources.resource_changed.connect(_on_resource_changed)
