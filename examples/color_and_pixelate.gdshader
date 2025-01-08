shader_type canvas_item;

#include "res://shaderlib/hsv.gdshaderinc"
#include "res://shaderlib/effects.gdshaderinc"

//!load ./swamp.jpg

void fragment() {
	COLOR = pixelate(TEXTURE, UV, 200.0);
	vec4 hsv = rgb2hsv(COLOR);
	COLOR = hsv_offset(COLOR, 0.65, .42-(hsv.y*.3), -.125);
	COLOR = hsv_multiply(COLOR, 1.0, 1.0, 1.25);
}
