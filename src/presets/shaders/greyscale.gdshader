shader_type canvas_item;

void fragment() {
	vec4 tex = texture(TEXTURE , UV);
	float b = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
	COLOR.r = b;
	COLOR.g = b;
	COLOR.b = b;
	COLOR.a = tex.a;
}
