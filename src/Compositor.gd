extends SubViewport

@onready var camera = %Camera
@onready var image_sprite = %ImageSprite
@onready var image_viewport_display = %ImageViewportDisplay

func update() -> Array: # returns error messages (strings)
	var errors = []
	var fit_image = false
	# load texture(s)
	Filesystem.clear_additional_images()
	# ... from //!load directive -> TEXTURE
	var m = ShaderDirectiveParser.parse_load_directive(Filesystem.shader)
	if len(m) < 1:
		errors.append("Didn't find a load directive!")
		return errors
	var original_image_path = Filesystem.get_absolute_path(m[1])
	if original_image_path != Filesystem.last_original_image_path:
		fit_image = true
	var err = Filesystem.load_original_image(original_image_path)
	if err != "":
		errors.append(err)
		image_viewport_display.hide()
		return errors
	# ... from //!load+ directives
	for n in ShaderDirectiveParser.parse_load_additional_directive(Filesystem.shader):
		err = Filesystem.load_additional_image(n[1], Filesystem.get_absolute_path(n[2]))
		if err != "":
			errors.append(err)
	if len(errors) > 0:
		return errors
	# apply textures
	image_sprite.texture = Filesystem.original_image
	image_sprite.offset = Filesystem.original_image.get_size() / 2
	self.size = Filesystem.original_image.get_size()
	var mat = ShaderMaterial.new()
	mat.shader = Filesystem.shader
	# ... as shader parameters
	for key in Filesystem.additional_images:
		mat.set_shader_parameter(
			key, # uniform param name
			Filesystem.additional_images[key])
	# assign material
	image_sprite.material = mat
	# Get viewport texture
	await RenderingServer.frame_post_draw # for good measure
	Filesystem.result = get_texture().get_image()
	image_sprite.material = null
	image_sprite.texture = ImageTexture.create_from_image(Filesystem.result)
	if fit_image:
		camera.fit_image()
	camera.update_vd_zoomlevel()
	image_viewport_display.show()
	# done
	return errors
