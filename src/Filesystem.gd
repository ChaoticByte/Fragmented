extends Node

@onready var shader: Shader = load("res://src/shader/template.gdshader")
var original_image: ImageTexture
var result: Image

var cwd = "."
var last_image_savepath = ""
var last_shader_savepath = ""
var last_original_image_path = ""

func get_absolute_path(p: String) -> String:
	# this only works on Linux!
	if !p.begins_with("/"):
		return self.cwd + "/" + p.lstrip("./")
	return p

func load_original_image(path: String):
	print("Load ", path)
	var img = Image.new()
	var err = img.load(path)
	if err == OK:
		original_image = ImageTexture.create_from_image(img)
		if path != self.last_original_image_path:
			self.last_original_image_path = path
		if self.last_image_savepath == "":
			self.last_image_savepath = path
	else:
		print("An error occured!")

func load_image(path: String) -> ImageTexture:
	print("Load ", path)
	return ImageTexture.create_from_image(Image.load_from_file(path))

func save_result(path: String):
	print("Export ", path)
	var err = self.result.save_png(path)
	if err != OK:
		print("An error occured!")
	else:
		self.last_image_savepath = path

func load_shader(path: String):
	print("Load ", path)
	var file = FileAccess.open(path, FileAccess.READ)
	var shader_code = file.get_as_text()
	self.shader = Shader.new()
	shader.code = shader_code
	if "/" in path: # update current working directory
		self.cwd = path.substr(0, path.rfind("/"))
	self.last_shader_savepath = path

func save_shader(path: String, content: String):
	print("Save ", path)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)
	if "/" in path: # update current working directory
		self.cwd = path.substr(0, path.rfind("/"))
	self.last_shader_savepath = path
