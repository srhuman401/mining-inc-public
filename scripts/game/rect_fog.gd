class_name FogOfWarRect
extends ColorRect

var world_center := Vector2(0,0)
var rect_size := Vector2(500,500)
@onready var mat = material

#var _last_rect_center: Vector2 = Vector2.ZERO

func _process(_delta):
	#var cam = get_viewport().get_camera_2d()
	var canvas_transform = get_viewport().get_canvas_transform()
	var screen_center = canvas_transform * world_center
	var zoom = canvas_transform.get_scale()
	#_last_rect_center = screen_center
	mat.set_shader_parameter("rect_center", screen_center)
	mat.set_shader_parameter("rect_size", rect_size * zoom)
	mat.set_shader_parameter("screen_size", get_viewport_rect().size)

func inside_rect(point: Vector2):
		var half = rect_size * 0.5
		return (
			point.x >= world_center.x - half.x and
			point.x <= world_center.x + half.x and
			point.y >= world_center.y - half.y and
			point.y <= world_center.y + half.y
		)
