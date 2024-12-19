extends SubViewport

@onready var camera = %Camera
@onready var image_sprite = %ImageSprite

var image_original_tex: ImageTexture
var image_result: Image
var load_regex: RegEx
var load_additional_regex: RegEx
var last_tex_path = ""

func _ready():
	load_regex = RegEx.new()
	load_additional_regex = RegEx.new()
	load_regex.compile(r'\/\/!load\s(.*)')
	load_additional_regex.compile(r'\/\/!load\+\s(\w*)\s(.*)')

func load_texture(path):
	print("Load ", path)
	var img = Image.new()
	var err = img.load(path)
	if err == OK:
		image_original_tex = ImageTexture.create_from_image(img)
		image_sprite.texture = image_original_tex
		image_sprite.offset = image_original_tex.get_size() / 2
		size = image_original_tex.get_size()
	else:
		print("An error occured!")

func get_absolute_path(p: String) -> String:
	if !p.begins_with("/"):
		return Globals.cwd + "/" + p.lstrip("./")
	return p

func update():
	# load images from //!load directive -> TEXTURE
	var regex_match = load_regex.search(Globals.shader.code)
	if regex_match == null: # Error!
		print("Didn't find any load directives!")
		return
	var tex_path = get_absolute_path(regex_match.strings[1])
	load_texture(tex_path) # load every time
	if tex_path != last_tex_path:
		camera.fit_image()
		last_tex_path = tex_path
	if Globals.last_image_savepath == "":
		Globals.last_image_savepath = tex_path
	image_sprite.texture = image_original_tex
	var mat = ShaderMaterial.new()
	mat.shader = Globals.shader
	# load images from //!load+ directives and apply them to
	# the material as shader parameters
	for m in load_additional_regex.search_all(Globals.shader.code):
		# this only works for Linux!
		var img_path = get_absolute_path(m.strings[2])
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
