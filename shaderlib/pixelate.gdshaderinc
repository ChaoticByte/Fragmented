
// pixelate by lowering uv resolution
vec4 pixelate(sampler2D tex, vec2 uv, float resolution_x) {
	vec2 texture_size = vec2(textureSize(tex, 0));
	vec2 ratio;
	if (texture_size.x > texture_size.y) {
		ratio = vec2(texture_size.x / texture_size.y, 1.0);
	}
	else {
		ratio = vec2(1.0, texture_size.y / texture_size.x);
	}
	vec2 r = ratio * resolution_x;
	return texture(tex, trunc(uv * r) / r);
}
