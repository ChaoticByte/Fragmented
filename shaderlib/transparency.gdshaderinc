
/*
	Alpha Blending a over b after Bruce A. Wallace
	source: https://en.wikipedia.org/wiki/Alpha_compositing
*/
vec4 alpha_blend(vec4 b, vec4 a) {
	float alpha = a.a + (b.a * (1.0 - a.a));
	vec3 col = ((a.rgb*a.a) + ((b.rgb*b.a) * (1.0 - a.a)) / alpha);
	return vec4(col.r, col.g, col.b, alpha);
}
