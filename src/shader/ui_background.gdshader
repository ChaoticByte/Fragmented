shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_linear_mipmap_anisotropic;

float rand(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
	vec2 new_uv;
	new_uv.x = mix(SCREEN_UV.x, rand(UV), 0.2);
	new_uv.y = mix(SCREEN_UV.y, rand(UV), 0.2);
	new_uv.x = mix(new_uv.x, rand(UV), -0.2);
	new_uv.y = mix(new_uv.y, rand(UV), -0.2);
	COLOR.rgb = clamp(textureLod(SCREEN_TEXTURE, new_uv, 10.0).rgb, 0.05, 0.7);
	COLOR.a = 1.0;
}
