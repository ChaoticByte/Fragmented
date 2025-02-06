extends Node

var cwd = "."

var shader_path = "":
	get():
		return shader_path
	set(v):
		var old = shader_path
		shader_path = v
		if "/" in v: # update current working directory
			cwd = v.substr(0, v.rfind("/"))
		if old != shader_path:
			store_last_opened_file()

var shader: Shader:
	get():
		print("Load ", shader_path)
		return load(shader_path)

var original_image: ImageTexture

var additional_images: Dictionary
var result: Image

var last_image_savepath = ""
var last_original_image_path = ""

func get_absolute_path(p: String) -> String:
	# this only works on Linux!
	if !p.begins_with("/"):
		return self.cwd + "/" + p.lstrip("./")
	return p

func load_original_image(path: String) -> String: # returns an error message
	print("Load ", path)
	var img = Image.new()
	var err = img.load(path)
	if err == OK:
		original_image = ImageTexture.create_from_image(img)
		if self.last_image_savepath == "" or path != self.last_original_image_path:
			self.last_image_savepath = path
		self.last_original_image_path = path
		return ""
	return error_string(err) + " " + path

func clear_additional_images():
	additional_images.clear()

func load_additional_image(key: String, path: String) -> String: # returns Error Message String
	print("Load ", path)
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

func store_last_opened_file():
	var f = FileAccess.open("user://last_opened", FileAccess.WRITE)
	if f != null:
		f.store_pascal_string(shader_path)
		f.flush()

func remember_last_opened_file():
	var f = FileAccess.open("user://last_opened", FileAccess.READ)
	if f != null:
		shader_path = f.get_pascal_string()
