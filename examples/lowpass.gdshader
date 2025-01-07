shader_type canvas_item;

//!load ./swamp.jpg

// Settings
const float threshold = 0.6;
//

void fragment() {
	vec4 tex = texture(TEXTURE , UV);
	COLOR.rgb = min(tex.rgb, vec3(threshold));
	COLOR.a = tex.a;
}
