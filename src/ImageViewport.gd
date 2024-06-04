extends SubViewport

@onready var image_sprite = $ImageSprite

var image_original_tex: ImageTexture
var image_result: Image

func set_original_image(image: Image):
	image_original_tex = ImageTexture.create_from_image(image)
	image_sprite.texture = image_original_tex
	image_sprite.offset = image_original_tex.get_size() / 2
	size = image_original_tex.get_size()

func update():
	if image_original_tex != null:
		image_sprite.texture = image_original_tex
		var mat = ShaderMaterial.new()
		mat.shader = Globals.shader
		image_sprite.material = mat
		# Get viewport texture
		await RenderingServer.frame_post_draw # for good measure
		image_result = get_texture().get_image()
		image_sprite.material = null
		image_sprite.texture = ImageTexture.create_from_image(image_result)

func get_result():
	return image_result
