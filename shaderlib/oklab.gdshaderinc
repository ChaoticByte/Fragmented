
/*
	OkLab and OkLCh
	For more details on oklab, see
		- https://bottosson.github.io/posts/oklab/
		- https://en.wikipedia.org/wiki/Oklab_color_space

	Color space conversion functions always work with vec4.
	The fourth value is always alpha.
*/

#include "res://shaderlib/common.gdshaderinc"

vec4 rgb2oklab(vec4 c) {
	float l = 0.4122214708f * c.r + 0.5363325363f * c.g + 0.0514459929f * c.b;
	float m = 0.2119034982f * c.r + 0.6806995451f * c.g + 0.1073969566f * c.b;
	float s = 0.0883024619f * c.r + 0.2817188376f * c.g + 0.6299787005f * c.b;

	float l_ = cbrt(l);
	float m_ = cbrt(m);
	float s_ = cbrt(s);

	return vec4(
		0.2104542553f*l_ + 0.7936177850f*m_ - 0.0040720468f*s_,
		1.9779984951f*l_ - 2.4285922050f*m_ + 0.4505937099f*s_,
		0.0259040371f*l_ + 0.7827717662f*m_ - 0.8086757660f*s_,
		c.a
	);
}

vec4 oklab2rgb(vec4 c) {
	float l_ = c.x + 0.3963377774f * c.y + 0.2158037573f * c.z;
	float m_ = c.x - 0.1055613458f * c.y - 0.0638541728f * c.z;
	float s_ = c.x - 0.0894841775f * c.y - 1.2914855480f * c.z;

	float l = l_*l_*l_;
	float m = m_*m_*m_;
	float s = s_*s_*s_;

	return vec4(
		+4.0767416621f * l - 3.3077115913f * m + 0.2309699292f * s,
		-1.2684380046f * l + 2.6097574011f * m - 0.3413193965f * s,
		-0.0041960863f * l - 0.7034186147f * m + 1.7076147010f * s,
		c.a
	);
}

vec4 oklab2oklch(vec4 c) {
	return vec4(
		c.x,
		sqrt((c.y * c.y) + (c.z * c.z)),
		atan(c.z, c.y),
		c.a
	);
}

vec4 oklch2oklab(vec4 c) {
	return vec4(
		c.x,
		c.y * cos(c.z),
		c.y * sin(c.z),
		c.a
	);
}
