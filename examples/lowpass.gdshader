shader_type canvas_item;

//!load ./swamp.jpg

// Settings
const float threshold = 0.5;
//

void fragment() {
	vec4 tex = texture(TEXTURE , UV);
	COLOR.r = min(tex.r, threshold);
	COLOR.g = min(tex.g, threshold);
	COLOR.b = min(tex.b, threshold);
	COLOR.a = tex.a;
}
