extends SubViewport

@onready var image_sprite = $ImageSprite

var image_original_tex: ImageTexture
var image_result: Image
var load_uniform_regex: RegEx

func _ready():
	load_uniform_regex = RegEx.new()
	load_uniform_regex.compile(r'\/\/!load\s(\w*)\s(.*)')

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
		# load images from //!load directives and apply them to
		# the material as shader parameters
		for m in load_uniform_regex.search_all(Globals.shader.code):
			# this only works for Linux!
			var img_path = m.strings[2]
			if !img_path.begins_with("/"):
				img_path = Globals.cwd + "/" + img_path.lstrip("./")
			#
			print("Load ", img_path)
			var u_image = Image.load_from_file(img_path)
			mat.set_shader_parameter(
				m.strings[1], # uniform param name
				ImageTexture.create_from_image(u_image))
		# assign material
		image_sprite.material = mat
		# Get viewport texture
		await RenderingServer.frame_post_draw # for good measure
		image_result = get_texture().get_image()
		image_sprite.material = null
		image_sprite.texture = ImageTexture.create_from_image(image_result)

func get_result():
	return image_result
