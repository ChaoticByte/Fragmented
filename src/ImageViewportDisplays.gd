extends Sprite2D

@onready var camera = get_parent().get_node("Camera")

func _process(_delta):
	if camera.zoom.x >= 1.5:
		texture_filter = TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	else:
		texture_filter = TEXTURE_FILTER_LINEAR
