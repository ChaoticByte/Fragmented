shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_linear_mipmap_anisotropic;

void fragment() {
	COLOR.rgb = clamp(textureLod(SCREEN_TEXTURE, SCREEN_UV, 10.0).rgb, 0.05, 0.7);
	COLOR.a = 1.0;
}
