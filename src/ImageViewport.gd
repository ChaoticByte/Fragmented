extends SubViewport

@onready var camera = %Camera
@onready var image_sprite = %ImageSprite
@onready var image_viewport_display = %ImageViewportDisplay

func update():
	var fit_image = false
	# load image from //!load directive -> TEXTURE
	var m = ShaderDirectiveParser.parse_load_directive(Filesystem.shader)
	if len(m) < 1:
		return # AAAAAAAa
	var original_image_path = Filesystem.get_absolute_path(m[1])
	if original_image_path != Filesystem.last_original_image_path:
		fit_image = true
	Filesystem.load_original_image(original_image_path)
	if Filesystem.original_image == null:
		image_viewport_display.hide()
		return
	image_sprite.texture = Filesystem.original_image
	image_sprite.offset = Filesystem.original_image.get_size() / 2
	self.size = Filesystem.original_image.get_size()
	var mat = ShaderMaterial.new()
	mat.shader = Filesystem.shader
	# load images from //!load+ directives and apply them to
	# the material as shader parameters
	for n in ShaderDirectiveParser.parse_load_additional_directive(Filesystem.shader):
		mat.set_shader_parameter(
			n[1], # uniform param name
			Filesystem.load_image(Filesystem.get_absolute_path(n[2]))
		)
	# assign material
	image_sprite.material = mat
	# Get viewport texture
	await RenderingServer.frame_post_draw # for good measure
	Filesystem.result = get_texture().get_image()
	image_sprite.material = null
	image_sprite.texture = ImageTexture.create_from_image(Filesystem.result)
	if fit_image:
		camera.fit_image()
	image_viewport_display.show()
