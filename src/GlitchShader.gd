extends Node

var target_sprite: Sprite2D

@onready var shader: Shader = ShaderPresets.presets[ShaderPresets.default_preset]

func apply():
	var mat = ShaderMaterial.new()
	mat.shader = shader
	target_sprite.material = mat
