shader_type canvas_item;

#include "res://shaderlib/transform.gdshaderinc"

//!load ./swamp.jpg
//!load+ img2 ./grass.png

uniform sampler2D img2: repeat_disable, filter_nearest;

void fragment() {
	vec4 grass = place_texture(img2, UV, TEXTURE_PIXEL_SIZE, vec2(0, .47), vec2(1));
	grass.rgb += (vec3(0.03, 0.07, 0.11) - ((UV.y - .8) * 0.15)); // color correction
	COLOR.rgb = mix(COLOR.rgb, grass.rgb, grass.a);
}
