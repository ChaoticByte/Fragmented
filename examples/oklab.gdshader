shader_type canvas_item;

#include "res://shaderlib/oklab.gdshaderinc"

//!load ./images/swamp.jpg

void fragment() {
	vec4 oklab = rgb2oklab(COLOR);
	vec4 oklch = oklab2oklch(oklab);
	oklch.z -= 2.0;
	COLOR = oklab2rgb(oklch2oklab(oklch));
}
