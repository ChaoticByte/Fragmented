extends Control

@onready var code_editor = %CodeEdit
@onready var open_shader_dialog = %OpenShaderDialog
@onready var save_shader_dialog = %SaveShaderDialog

@onready var image_viewport = %ImageViewport
@onready var ui_control_filesave = %SaveImageDialog

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
	"sampler2D", "isampler2D", "usampler2D",
	"sampler2DArray", "isampler2DArray", "usampler2DArray",
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
	"SCREEN_UV", "SCREEN_PIXEL_SIZE",
	"POINT_COORD",
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

func _ready():
	code_editor.code_completion_enabled = true
	code_editor.syntax_highlighter = ShaderSyntaxHighlighter.new()
	update()

func _input(event):
	if event.is_action_pressed("apply_shader"):
		_on_apply_shader_button_pressed()
	elif event.is_action_pressed("save_shader"):
		accept_event() # Event is now handled.
		_on_save_shader_button_pressed()

func update():
	code_editor.text = Globals.shader.code

func _on_open_shader_button_pressed():
	open_shader_dialog.show()

func _on_save_shader_button_pressed():
	if Globals.last_shader_savepath == "":
		save_shader_dialog.current_file = "shader.gdshader"
	else:
		save_shader_dialog.current_path = Globals.last_shader_savepath
	save_shader_dialog.show()

func _on_open_shader_dialog_file_selected(path: String):
	print("Load ", path)
	var file = FileAccess.open(path, FileAccess.READ)
	var shader_code = file.get_as_text()
	var shader = Shader.new()
	shader.code = shader_code
	Globals.shader = shader
	if "/" in path: # update current working directory
		Globals.cwd = path.substr(0, path.rfind("/"))
	image_viewport.update()
	update()
	Globals.last_shader_savepath = path

func _on_save_shader_dialog_file_selected(path):
	print("Save ", path)
	var file = FileAccess.open(path, FileAccess.WRITE)
	var content = code_editor.text
	file.store_string(content)
	if "/" in path: # update current working directory
		Globals.cwd = path.substr(0, path.rfind("/"))
	Globals.last_shader_savepath = path

func _on_apply_shader_button_pressed():
	var shader = Shader.new()
	shader.code = code_editor.text
	Globals.shader = shader
	image_viewport.update()

func _on_save_image_button_pressed():
	if image_viewport.get_result() != null:
		ui_control_filesave.current_path = Globals.last_image_savepath
		ui_control_filesave.show()

func _on_save_image_dialog_file_selected(path):
	print("Export ", path)
	var err = image_viewport.get_result().save_png(path)
	if err != OK:
		print("An error occured!")
	else:
		Globals.last_image_savepath = path
