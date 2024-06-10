extends Control

@onready var preset_options = $PresetOptions
@onready var code_editor = $CodeEdit
@onready var open_shader_dialog = $OpenShaderDialog
@onready var save_shader_dialog = $SaveShaderDialog
var selected_preset_name = ShaderPresets.default_preset
var last_save_filepath = ""

# # # # # # # # # # #
# GDShader keywords #
# https://github.com/godotengine/godot/blob/e96ad5af98547df71b50c4c4695ac348638113e0/servers/rendering/shader_language.cpp
# https://github.com/godotengine/godot/blob/e96ad5af98547df71b50c4c4695ac348638113e0/servers/rendering/shader_types.cpp
#
const gdshader_boolean_values = [
	"true", "false"
]
const gdshader_datatypes = [
	"void",
	"bool", "bvec2", "bvec3", "bvec4",
	"int", "ivec2", "ivec3", "ivec4",
	"uint", "uvec2", "uvec3", "uvec4",
	"float", "vec2", "vec3", "vec4",
	"mat2", "mat3", "mat4",
	"sample2D", "isampler2D", "usample2D",
	"sampler2DArray", "isample2DArray", "usample2DArray",
	"sample3D", "isampler3D", "usample3D",
	"samplerCube", "sampleCubeArray"
]
const gdshader_precision_modifiers = [
	"lowp", "mediump", "heighp"
]
const gdshader_global_space_keywords = [
	"uniform", "group_uniforms", "varying", "const",
	"struct", "shader_type", "render_mode"
]
const gdshader_uniform_qualifiers = [
	"instance", "global"
]
const gdshader_block_keywords = [
	"if", "else",
	"for", "while", "do",
	"switch", "case",
	"default", "break", "continue",
	"return", "discard"
]
const gdshader_function_specifier_keywords = [
	"in", "out", "inout"
]
const gdshader_hints = [
	"source_color", "hint_range", "instance_index"
]
const gdshader_sampler_hints = [
	"hint_normal",
	"hint_default_white", "hint_default_black", "hint_default_transparent",
	"hint_anisotropy",
	"hint_roughness_r", "hint_roughness_g", "hint_roughness_b", "hint_roughness_a",
	"hint_roughness_normal", "hint_roughness_gray",
	"hint_screen_texture", "hint_normal_roughness_texture",
	"hint_depth_texture",
	"filter_nearest", "filter_linear",
	"filter_nearest_mipmap", "filter_linear_mipmap",
	"filter_nearest_mipmap_anisotropic", "filter_linear_mipmap_anisotropic",
	"repeat_enable", "repeat_disable"
]
const gdshader_builtin_functions = [
	"radians", "degrees",
	"sin", "cos", "tan", "asin", "acos", "atan", "sinh", "cosh", "tanh",
	"asinh", "acosh", "atanh",
	"pow", "exp", "log", "exp2", "log2", "sqrt", "inversesqrt",
	"abs", "sign", "floor", "trunc", "round", "roundEven", "ceil", "fract",
	"mod", "modf", "min", "max", "clamp",
	"mix", "step", "smoothstep",
	"isnan", "isinf",
	"floatBitsToInt", "floatBitsToUint", "intBitsToFloat", "uintBitsToFloat",
	"length", "distance",
	"dot", "cross",
	"normalize", "reflect", "refract", "faceforward",
	"matrixCompMult", "outerProduct", "transpose",
	"determinant", "inverse",
	"lessThan", "greaterThan", "lessThanEqual", "greaterThanEqual",
	"equal", "notEqual",
	"any", "all", "not",
	"textureSize", "texture", "textureProj", "textureLod", "texelFetch",
	"textureProjLod", "textureGrad", "textureProjGrad", "textureGather",
	"textureQueryLod", "textureQueryLevels",
	"dFdx", "dFdxCoarse", "dFdxFine", "dFdy", "dFdyCoarse", "dFdyFine",
	"fwidth", "fwidthCoarse", "fwidthFine"
]
const gdshader_sub_functions = [
	"length", "fma",
	"packHalf2x16", "packUnorm2x16", "packSnorm2x16", "packUnorm4x8", "packSnorm4x8",
	"unpackHalf2x16", "unpackUnorm2x16", "unpackSnorm2x16", "unpackUnorm4x8", "unpackSnorm4x8",
	"bitfieldExtract", "bitfieldInsert", "bitfieldReverse", "bitCount",
	"findLSB", "findMSB",
	"umulExtended", "imulExtended",
	"uaddCarry", "usubBorrow",
	"ldexp", "frexp"
]
const gdshader_builtins = [
	"TIME", "PI", "TAU", "E",
	"VERTEX",
	"UV",
	"COLOR",
	"POINT_SIZE",
	"MODEL_MATRIX", "CANVAS_MATRIX", "SCREEN_MATRIX",
	"INSTANCE_CUSTOM", "INSTANCE_ID",
	"VERTEX_ID",
	"AT_LIGHT_PASS",
	"TEXTURE_PIXEL_SIZE",
	"CUSTOM0", "CUSTOM1",
	"SHADOW_VERTEX", "LIGHT_VERTEX",
	"FRAGCOORD",
	"NORMAL", "NORMAL_MAP", "NORMAL_MAP_DEPTH",
	"TEXTURE", "NORMAL_TEXTURE",
	"SPECULAR_SHININESS_TEXTURE", "SPECULAR_SHININESS",
	"SCREEN_UV", "SCREEN_PIXEL_SIZE",
	"POINT_COORD",
	"LIGHT_COLOR", "LIGHT_POSITION", "LIGHT_DIRECTION",
	"LIGHT_ENERGY", "LIGHT_IS_DIRECTIONAL", "LIGHT",
	"SHADOW_MODULATE"
]
#
# configure Highlighter
#
class ShaderSyntaxHighlighter extends CodeHighlighter:
	func _init():
		add_color_region("//", "", Color.WEB_GRAY, true)
		add_color_region("/*", "*/", Color.WEB_GRAY, false)
		function_color = Color.INDIAN_RED
		for k in gdshader_boolean_values:
			keyword_colors[k] = Color.INDIAN_RED
		for k in (	gdshader_datatypes
					+ gdshader_hints
					+ gdshader_sampler_hints
					+ gdshader_global_space_keywords
					+ gdshader_function_specifier_keywords
					+ gdshader_precision_modifiers
					+ gdshader_uniform_qualifiers):
			keyword_colors[k] = Color.ORCHID;
		for k in gdshader_block_keywords:
			keyword_colors[k] = Color.CORAL
		for k in gdshader_builtins:
			keyword_colors[k] = Color.DARK_TURQUOISE
		member_variable_color = Color.LIGHT_BLUE
		number_color = Color.AQUA
		symbol_color = Color.GRAY
#
# and code completion
#
func _on_code_edit_code_completion_requested():
	for k in gdshader_boolean_values:
		code_editor.code_completion_prefixes.append(k)
		code_editor.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, k, k, Color.INDIAN_RED)
	for k in (	gdshader_datatypes
				+ gdshader_hints
				+ gdshader_sampler_hints
				+ gdshader_global_space_keywords
				+ gdshader_function_specifier_keywords
				+ gdshader_precision_modifiers
				+ gdshader_uniform_qualifiers):
		code_editor.code_completion_prefixes.append(k)
		code_editor.add_code_completion_option(CodeEdit.KIND_CLASS, k, k, Color.ORCHID)
	for k in gdshader_block_keywords:
		code_editor.code_completion_prefixes.append(k)
		code_editor.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, k, k, Color.CORAL)
	for k in gdshader_builtins:
		code_editor.code_completion_prefixes.append(k)
		code_editor.add_code_completion_option(CodeEdit.KIND_CONSTANT, k, k, Color.DARK_TURQUOISE)
	for k in gdshader_builtin_functions + gdshader_sub_functions:
		code_editor.code_completion_prefixes.append(k)
		code_editor.add_code_completion_option(CodeEdit.KIND_FUNCTION, k, k+"(", Color.INDIAN_RED)
	code_editor.update_code_completion_options(true)
#
# # # # # # # # # # # #

func _camera_freeze():
	Globals.camera_freeze = true

func _camera_unfreeze():
	Globals.camera_freeze = false

func _ready():
	code_editor.code_completion_enabled = true
	code_editor.syntax_highlighter = ShaderSyntaxHighlighter.new()
	for c in get_children():
		c.connect("mouse_entered", _camera_freeze)
		c.connect("mouse_exited", _camera_unfreeze)
	update()

func _input(event):
	if event.is_action_pressed("apply_shader"):
		_on_apply_shader_button_pressed()
	elif event.is_action_pressed("save_shader"):
		accept_event() # Event is now handled.
		_on_save_shader_button_pressed()

func _on_preset_options_item_selected(index):
	selected_preset_name = preset_options.get_item_text(index)
	Globals.shader = ShaderPresets.presets[selected_preset_name]
	Globals.target_viewport.update()
	update()
	last_save_filepath = ""

func update():
	preset_options.clear()
	# the following lines are weird af
	var presets: Array[String] = []
	var current_p_idx = 0
	for p in ShaderPresets.presets:
		presets.append(p)
		if p == selected_preset_name:
			current_p_idx = len(presets) - 1
		preset_options.add_item(p)
	preset_options.select(current_p_idx)
	# weirdness ends here
	code_editor.text = Globals.shader.code

func _on_open_shader_button_pressed():
	open_shader_dialog.show()

func _on_save_shader_button_pressed():
	if last_save_filepath == "":
		save_shader_dialog.current_file = selected_preset_name + "_custom.gdshader"
	else:
		save_shader_dialog.current_path = last_save_filepath
	save_shader_dialog.show()

func _on_open_shader_dialog_file_selected(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var shader_code = file.get_as_text()
	var shader = Shader.new()
	shader.code = shader_code
	Globals.shader = shader
	Globals.target_viewport.update()
	update()
	last_save_filepath = path

func _on_save_shader_dialog_file_selected(path):
	var file = FileAccess.open(path, FileAccess.WRITE)
	var content = Globals.shader.code
	file.store_string(content)
	last_save_filepath = path

func _on_apply_shader_button_pressed():
	var shader = Shader.new()
	shader.code = code_editor.text
	Globals.shader = shader
	Globals.target_viewport.update()
