extends Label

func _ready():
	text = ProjectSettings.get_setting("application/config/name") \
		+ " " \
		+ ProjectSettings.get_setting("application/config/version") \
		+ " | Godot " \
		+ Engine.get_version_info()["string"]
