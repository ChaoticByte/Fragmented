/*
	Kuwahara Filter, adapted
	original code: https://godotshaders.com/shader/generalized-kuwahara/
	original authors:
		- https://godotshaders.com/author/firerabbit/
		- https://github.com/GarrettGunnell (Acerola)
	license of the original code:

	MIT License

	Copyright (c) 2022 Garrett Gunnell
	Copyright (c) 2024 Firerabbit

	Permission is hereby granted, free of charge, to any person obtaining a copy of this
	software and associated documentation files (the "Software"), to deal in the Software
	without restriction, including without limitation the rights to use, copy, modify, merge,
	publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
	to whom the Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all copies
	or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
	THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
	IN THE SOFTWARE.
*/

vec3 kuwahara(
	sampler2D texture,
	vec2 uv,
	int kernel_size,	 // should be > 2 - high values will affect performance
	float hardness,		 // should be in the range of 1.0 - 100.0
	float sharpness,	 // should be in the range of 1.0 - 18.0
	float zero_crossing, // should be in the range of 0.5 - 2.0
	float zeta,			 // should be in the range of 0.01 - 3.0
	int n				 // number of iterations, should be 8, must be <= 8
)  {
	vec2 texelSize = vec2(1.0 / vec2(textureSize(texture, 0)));
	vec4 m[8];
	vec3 s[8];

	int kernel_radius = kernel_size / 2;

	float sin_zero_crossing = sin(zero_crossing);
	float eta = (zeta + cos(zero_crossing)) / (sin_zero_crossing * sin_zero_crossing);

	for (int k = 0; k < n; ++k) {
		m[k] = vec4(0.0f);
		s[k] = vec3(0.0f);
	}

	for (int y = -kernel_radius; y <= kernel_radius; ++y) {
		for (int x = -kernel_radius; x <= kernel_radius; ++x) {
			vec2 v = vec2(float(x), float(y)) / float(kernel_radius);
			vec3 c = texture(texture, uv + vec2(float(x), float(y)) * texelSize.xy).rgb;
			c = clamp(c, 0.0f, 1.0f);
			float sum = 0.0f;
			float w[8];
			float z, vxx, vyy;

			/* Calculate Polynomial Weights */
			vxx = zeta - eta * v.x * v.x;
			vyy = zeta - eta * v.y * v.y;
			z = max(0, v.y + vxx);
			w[0] = z * z;
			sum += w[0];
			z = max(0, -v.x + vyy);
			w[2] = z * z;
			sum += w[2];
			z = max(0, -v.y + vxx);
			w[4] = z * z;
			sum += w[4];
			z = max(0, v.x + vyy);
			w[6] = z * z;
			sum += w[6];
			v = sqrt(2.0f) / 2.0f * vec2(v.x - v.y, v.x + v.y);
			vxx = zeta - eta * v.x * v.x;
			vyy = zeta - eta * v.y * v.y;
			z = max(0, v.y + vxx);
			w[1] = z * z;
			sum += w[1];
			z = max(0, -v.x + vyy);
			w[3] = z * z;
			sum += w[3];
			z = max(0, -v.y + vxx);
			w[5] = z * z;
			sum += w[5];
			z = max(0, v.x + vyy);
			w[7] = z * z;
			sum += w[7];

			float g = exp(-3.125f * dot(v,v)) / sum;

			for (int k = 0; k < 8; ++k) {
				float wk = w[k] * g;
				m[k] += vec4(c * wk, wk);
				s[k] += c * c * wk;
			}
		}
	}

	vec4 output = vec4(0.0f);
	for (int k = 0; k < n; ++k) {
		m[k].rgb /= m[k].w;
		s[k] = abs(s[k] / m[k].w - m[k].rgb * m[k].rgb);
		float sigma2 = s[k].r + s[k].g + s[k].b;
		float w = 1.0f / (1.0f + pow(hardness * 1000.0f * sigma2, 0.5f * sharpness));
		output += vec4(m[k].rgb * w, w);
	}

	return clamp(output / output.w, 0.0f, 1.0f).rgb;
}
