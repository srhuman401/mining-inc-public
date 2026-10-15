extends ScrollContainer

func _ready():
	$FlowContainer.custom_minimum_size.x = \
		size.x
