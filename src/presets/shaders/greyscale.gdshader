shader_type canvas_item;

void fragment() {
	// TODO: not only r
	vec4 tex = texture(TEXTURE , UV);
	COLOR.r = tex.r;
	COLOR.g = tex.r;
	COLOR.b = tex.r;
	COLOR.a = tex.a;
}
