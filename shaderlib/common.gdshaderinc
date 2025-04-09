
// inefficient cuberoot function
float cbrt(float x) {
	return pow(x, 1.0/3.0);
}

/*
	Alpha Blending a over b after Bruce A. Wallace
	source: https://en.wikipedia.org/wiki/Alpha_compositing
*/
vec4 alpha_blend(vec4 b, vec4 a) {
	float alpha = a.a + (b.a * (1.0 - a.a));
	vec3 col = ((a.rgb*a.a) + ((b.rgb*b.a) * (1.0 - a.a)) / alpha);
	return vec4(col.r, col.g, col.b, alpha);
}

/*
	Rotate UV
*/

vec2 rotateUV(vec2 uv, float rotation, vec2 center) {
	float cosRot = cos(rotation);
	float sinRot = sin(rotation);
    return vec2(
		cosRot * (uv.x - center.x) + sinRot * (uv.y - center.y) + center.x,
        cosRot * (uv.y - center.y) - sinRot * (uv.x - center.x) + center.y);
}
