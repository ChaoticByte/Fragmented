
/* glslSmartDenoise by Michele Morrone, adapted
original code: https://github.com/BrutPitt/glslSmartDeNoise
license of the original code:
BSD 2-Clause License

Copyright (c) 2019-2020 Michele Morrone
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#define INV_SQRT_OF_2PI 0.39894228040143267793994605993439  // 1.0/SQRT_OF_2PI
#define INV_PI 0.31830988618379067153776752674503

vec4 smart_denoise(sampler2D tex, vec2 uv, float sigma, float kSigma, float threshold) {
	float radius = round(kSigma*sigma);
	float radQ = radius * radius;

	float invSigmaQx2 = .5 / (sigma * sigma);      // 1.0 / (sigma^2 * 2.0)
	float invSigmaQx2PI = INV_PI * invSigmaQx2;    // 1/(2 * PI * sigma^2)

	float invThresholdSqx2 = .5 / (threshold * threshold);     // 1.0 / (sigma^2 * 2.0)
	float invThresholdSqrt2PI = INV_SQRT_OF_2PI / threshold;   // 1.0 / (sqrt(2*PI) * sigma^2)

	vec4 centrPx = texture(tex,uv);

	float zBuff = 0.0;
	vec4 aBuff = vec4(0.0);
	vec2 size = vec2(textureSize(tex, 0));

	for (float dx = -radius; dx <= radius; dx++) {
		float pt = sqrt(radQ - dx * dx);       // pt = yRadius: have circular trend
		for (float dy = -pt; dy <= pt; dy++) {
			vec2 d = vec2(dx, dy);
			float blurFactor = exp( -dot(d, d) * invSigmaQx2 ) * invSigmaQx2PI;

			vec4 walkPx =  texture(tex,uv+d/size);
			vec4 dC = walkPx-centrPx;
			float deltaFactor = exp(-dot(dC, dC) * invThresholdSqx2) * invThresholdSqrt2PI * blurFactor;

			zBuff += deltaFactor;
			aBuff += deltaFactor*walkPx;
		}
	}
	return aBuff/zBuff;
}
