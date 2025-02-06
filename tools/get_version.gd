extends SceneTree

# godot --headless --no-header -s tools/get_version.gd

func _init() -> void:
	print(ProjectSettings.get_setting("application/config/version"))
	quit(0)
