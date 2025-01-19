shader_type canvas_item;

//!load ./images/swamp.jpg
#include "res://shaderlib/blur.gdshaderinc"

void fragment() {
	COLOR = gaussian_blur(TEXTURE, UV, 48, 24.0);
}
