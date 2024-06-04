extends SubViewport

@onready var image_sprite = $ImageSprite

var image_original: ImageTexture

func set_original_image(image: Image):
	image_original = ImageTexture.create_from_image(image)
	image_sprite.texture = image_original
	image_sprite.offset = image_original.get_size() / 2
	size = image_original.get_size()
