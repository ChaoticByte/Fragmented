extends SubViewport

@onready var camera = %Camera
@onready var image_sprite = %ImageSprite
@onready var image_viewport_display = %ImageViewportDisplay

var _fragment_function_regex: RegEx = RegEx.create_from_string(r'\s*void\s+fragment\s*\(\s*\)\s*{\s*')

func validate_shader_compilation(shader: Shader) -> bool:
	# Inject code to validate shader compilation
	var shader_code = shader.code;
	# -> get position of fragment shader
	var fragment_function_match = _fragment_function_regex.search(shader.code)
	if fragment_function_match == null:
		return false
	# -> inject uniform
	var uniform_name = "shader_compilation_validate_" + str(randi_range(999999999, 100000000))
	var uniform_code_line = "\nuniform bool " + uniform_name + ";\n"
	shader_code = shader_code.insert(fragment_function_match.get_start(), uniform_code_line)
	# -> inject variable access to prevent that the uniform gets optimized away
	shader_code = shader_code.insert(fragment_function_match.get_end() + len(uniform_code_line), "\n" + uniform_name + ";\n")
	# apply shader code
	shader.code = shader_code
	# test if uniform list is empty -> if it is empty, the shader compilation failed
	return len(shader.get_shader_uniform_list()) > 0

func inject_step_uniform(shader_code: String) -> Shader:
	var shader = Shader.new()
	# this should run after validate_shader_compilation()
	var fragment_function_match = _fragment_function_regex.search(shader_code)
	shader.code = shader_code.insert(fragment_function_match.get_start(), "\nuniform int STEP;")
	return shader

func update() -> Array: # returns error messages (strings)
	# inject STEP uniform & get number of steps
	var shader: Shader = inject_step_uniform(Filesystem.shader_code)
	var steps: int = ShaderDirectiveParser.parse_steps_directive(shader.code)
	# validate shader
	if not validate_shader_compilation(shader):
		return ["Shader compilation failed!"]
	var errors = []
	# load texture(s) from //!load directive -> TEXTURE
	var m = ShaderDirectiveParser.parse_load_directive(shader.code)
	if len(m) < 1:
		errors.append("Didn't find a load directive!")
		return errors
	var original_image_path = Filesystem.get_absolute_path(m[1])
	var fit_image = false
	if original_image_path != Filesystem.last_original_image_path:
		fit_image = true
	var err = Filesystem.load_original_image(original_image_path)
	if err != "":
		errors.append(err)
		image_viewport_display.hide()
		return errors
	# ... from //!load+ directives
	Filesystem.clear_additional_images()
	for n in ShaderDirectiveParser.parse_load_additional_directive(shader.code):
		err = Filesystem.load_additional_image(n[1], Filesystem.get_absolute_path(n[2]))
		if err != "":
			errors.append(err)
	if len(errors) > 0:
		return errors
	# apply textures
	image_sprite.texture = Filesystem.original_image
	image_sprite.offset = Filesystem.original_image.get_size() / 2
	self.size = Filesystem.original_image.get_size()
	# create shader material
	var mat = ShaderMaterial.new()
	mat.shader = shader
	# add images as shader parameters
	for key in Filesystem.additional_images:
		mat.set_shader_parameter(
			key, # uniform param name
			Filesystem.additional_images[key])
	# assign material
	image_sprite.material = mat
	# iterate n times
	for i in range(steps):
		# set STEP param
		mat.set_shader_parameter("STEP", i)
		# Get viewport texture
		await RenderingServer.frame_post_draw # wait for next frame to get drawn
		Filesystem.result = get_texture().get_image()
		image_sprite.texture = ImageTexture.create_from_image(Filesystem.result)
	image_sprite.material = null
	if fit_image:
		camera.fit_image()
	camera.update_vd_zoomlevel()
	image_viewport_display.show()
	# done
	return errors
