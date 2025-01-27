extends Node

const BATCH_MODE_SUPPORTED_EXTS = [
	".bmp", ".dds", ".exr", ".hdr", ".jpeg", ".jpg", ".ktx", ".png", ".svg", ".webp"
]

@onready var editor_window = %EditorWindow
@onready var ui_container = %UserInterfaceContainer
@onready var app_name = ProjectSettings.get_setting("application/config/name")

func show_help():
	print(
		"Usage:\n\n",
		"./Fragmented cmd --shader PATH [--load-image PATH]\n\n",
		"  --shader PATH      The path to the shader\n",
		"  --output PATH      Where to write the resulting image to.\n",
		"                     In batch mode, this must be a folder.\n",
		"  --load-image PATH  The path to the image. This will overwrite the\n",
		"                     load directive of the shader file.\n",
		"                     Passing a folder activates batch mode.\n",
		"                     (optional)\n")

func parse_custom_cmdline(args: PackedStringArray):
	var kwargs: Dictionary = {"--shader": null, "--output": null, "--load-image": null}
	var args_len = args.size()
	var i = 0
	while i < args_len:
		var a = args[i]
		if a in kwargs && args_len > i+1:
			i += 1
			kwargs[a] = args[i]
		i += 1
	return kwargs

func cli_handle_errors(errors: Array) -> int:
	# returns number of errors
	var n_errors = errors.size()
	if n_errors > 0:
		print("One or more errors occurred.")
		for e in errors:
			printerr(e)
	return n_errors

func _ready():
	var args = OS.get_cmdline_args()
	if "cmd" in args: # commandline interface
		if "help" in args:
			show_help()
			get_tree().quit(1)
			return
		var kwargs: Dictionary = parse_custom_cmdline(args)
		if kwargs["--shader"] == null or kwargs["--output"] == null:
			show_help()
			get_tree().quit(1)
			return
		var batch_mode = false
		var load_image_dir: DirAccess
		if kwargs["--load-image"] != null:
			load_image_dir = DirAccess.open(kwargs["--load-image"])
			if load_image_dir != null:
				# batch mode
				if DirAccess.open(kwargs["--output"]) == null:
					printerr("If --load-image is a directory, --output has to be one too.\n")
					show_help()
					get_tree().quit(1)
					return
				else:
					batch_mode = true
		#
		Filesystem.load_shader(kwargs["--shader"])
		#
		if batch_mode:
			var in_dir_path = load_image_dir.get_current_dir()
			var out_dir_path: String = kwargs["--output"].rstrip("/")
			for f in load_image_dir.get_files():
				var supported = false
				for e in BATCH_MODE_SUPPORTED_EXTS:
					if f.ends_with(e):
						supported = true
						break
				if supported:
					f = in_dir_path + "/" + f
					print(f)
					var errors = await $Compositor.update(f)
					if cli_handle_errors(errors) == 0:
						var filename = out_dir_path + "/" + f.substr(f.rfind("/"), -1)
						Filesystem.save_result(filename)
					else:
						get_tree().quit(1)
						return
			get_tree().quit(0)
		else:
			var errors = []
			if kwargs["--load-image"] == null:
				errors = await $Compositor.update()
			else:
				errors = await $Compositor.update(kwargs["--load-image"])
			if cli_handle_errors(errors) == 0:
				Filesystem.save_result(kwargs["--output"])
				get_tree().quit(0)
			else:
				get_tree().quit(1)
	else:
		update_title()
		# position windows
		get_window().position = Vector2i(
			editor_window.position.x + editor_window.size.x + 50,
			editor_window.position.y)
		get_window().min_size = Vector2i(400, 400)
		editor_window.min_size = Vector2i(560, 400)
		editor_window.show()
		# Load last opened file
		Filesystem.remember_last_opened_file()
		if Filesystem.last_shader_savepath != "":
			ui_container.get_node("Editor")._on_open_shader_dialog_file_selected(Filesystem.last_shader_savepath)

func update_title(current_file: String = ""):
	if current_file == "":
		get_window().title = app_name + " - Viewer"
		editor_window.title = app_name + " - Editor"
	else:
		get_window().title = current_file + " - " + app_name + " - Viewer"
		editor_window.title = current_file + " - " + app_name + " - Editor"
