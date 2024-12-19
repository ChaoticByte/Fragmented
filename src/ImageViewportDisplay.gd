extends Sprite2D

func update_zoom_texture_filter(zoom: Vector2):
	if zoom.x >= 1.5:
		texture_filter = TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	else:
		texture_filter = TEXTURE_FILTER_LINEAR
