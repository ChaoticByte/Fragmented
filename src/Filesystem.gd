extends Node

@onready var template_shader: Shader = load("res://src/shader/template.gdshader")
@onready var shader: Shader = template_shader.duplicate()

var original_image: ImageTexture
var additional_images: Dictionary
var result: Image

var cwd = "."
var last_image_savepath = ""
var last_shader_savepath = ""
var last_original_image_path = ""

func reset():
	self.shader = self.template_shader.duplicate()
	self.last_image_savepath = ""
	self.last_shader_savepath = ""
	self.last_original_image_path = ""
	self.original_image = null
	self.result = null

func get_absolute_path(p: String) -> String:
	# this only works on Linux!
	if !p.begins_with("/"):
		return self.cwd + "/" + p.lstrip("./")
	return p

func load_original_image(path: String) -> String: # returns an error message
	var img = Image.new()
	var err = img.load(path)
	if err == OK:
		original_image = ImageTexture.create_from_image(img)
		if path != self.last_original_image_path:
			self.last_original_image_path = path
		if self.last_image_savepath == "":
			self.last_image_savepath = path
		return ""
	return error_string(err) + " " + path

func clear_additional_images():
	additional_images.clear()

func load_additional_image(key: String, path: String) -> String: # returns Error Message String
	var img = Image.new()
	var err = img.load(path)
	if err == OK:
		additional_images[key] = ImageTexture.create_from_image(img)
		return ""
	else:
		return error_string(err) + " " + path

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

func save_shader(path: String):
	print("Save ", path)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(self.shader.code)
	if "/" in path: # update current working directory
		self.cwd = path.substr(0, path.rfind("/"))
	self.last_shader_savepath = path
