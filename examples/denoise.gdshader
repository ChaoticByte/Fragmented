shader_type canvas_item;

//!load ./images/noisy.png

#include "res://shaderlib/denoise.gdshaderinc"

void fragment() {
	COLOR = smart_denoise(TEXTURE, UV, 12.0, 1.0, .12);
}
