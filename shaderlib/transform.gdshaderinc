
// Load in a texture from a sampler2D with an offset and scale
// See examples/place_texture.gdshader
vec4 place_texture(sampler2D sampler, vec2 uv, vec2 texture_pixel_size, vec2 offset, vec2 scale) {
	vec2 texture_size = vec2(textureSize(sampler, 0));
	// position of current pixel; sample color c
	vec2 pos = (uv - offset) / (texture_size*texture_pixel_size) / scale;
	vec4 c = texture(sampler, pos);
	// top-left bounds
	vec2 a = offset;
	// bottom-right bounds
	vec2 b = offset + (texture_size*texture_pixel_size) * scale;
	// check bounds
	if (
		a.x  < uv.x && a.y  < uv.y
		&& b.x > uv.x && b.y > uv.y
	) { return c; } // within bounds -> return color
	return vec4(0); // not within bounds -> return transparency
}
