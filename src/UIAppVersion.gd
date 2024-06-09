extends Label

func _ready():
	text = "v" + ProjectSettings.get_setting("application/config/version")
