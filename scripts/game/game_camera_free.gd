extends Camera2D
 
@export_category("The Sky")
@export var sky_rect: ColorRect

@export_category("FreeCamera")
@export var pan_speed: float = 1.0
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0
var _dragged: bool = false

@export var limit_height: float = -151.2

#func _process(delta: float) -> void:
	#sky_rect.scale.x = clamp(zoom.x, 1.0, 100.0)
	#sky_rect.scale.y = clamp(zoom.y, 1.0, 100.0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				_dragged = true
			else:
				_dragged = false
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_set_zoom_level(zoom - Vector2(zoom_speed, zoom_speed))
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_set_zoom_level(zoom + Vector2(zoom_speed, zoom_speed))
	
	if event is InputEventMouseMotion and _dragged:
		position -= event.relative * zoom 
		if position.y <= limit_height:
			position.y = limit_height

func _set_zoom_level(new_zoom: Vector2) -> void:
	var z = clamp(new_zoom.x, min_zoom, max_zoom)
	zoom = Vector2(z, z)
