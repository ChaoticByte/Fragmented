shader_type canvas_item;

#include "res://shaderlib/place_texture.gdshaderinc"
#include "res://shaderlib/common.gdshaderinc"

//!load ./images/swamp.jpg
//!load+ img2 ./images/grass.png

uniform sampler2D img2: repeat_disable, filter_nearest;

void fragment() {
	vec4 grass = place_texture(img2, UV, TEXTURE_PIXEL_SIZE, vec2(0, .47), vec2(1));
	grass.rgb += (vec3(0.02, 0.07, 0.1) - ((UV.y - .8) * 0.15)); // color correction
	COLOR = alpha_blend(COLOR, grass);
}
