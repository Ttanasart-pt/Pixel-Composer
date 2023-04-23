// Source: https://www.geeks3d.com/20110405/fxaa-fast-approximate-anti-aliasing-demo-glsl-opengl-test-radeon-geforce/3/
#define FXAA_REDUCE_MIN (1.0 / 128.0)
#define FXAA_REDUCE_MUL (1.0 / 8.0)
#define FXAA_SPAN_MAX 8.0

varying vec4 v_vFragPos;

uniform vec2 u_vTexelPS;

/// @param tex     Input texture.
/// @param fragPos Output of FXAAFragPos.
/// @param texel   vec2(1.0 / textureWidth, 1.0 / textureHeight)
vec4 FXAA(sampler2D tex, vec4 fragPos, vec2 texel)
{
/*---------------------------------------------------------*/
	vec3 rgbNW = texture2D(tex, fragPos.zw).xyz;
	vec3 rgbNE = texture2D(tex, fragPos.zw + vec2(1.0, 0.0) * texel).xyz;
	vec3 rgbSW = texture2D(tex, fragPos.zw + vec2(0.0, 1.0) * texel).xyz;
	vec3 rgbSE = texture2D(tex, fragPos.zw + vec2(1.0, 1.0) * texel).xyz;
	vec3 rgbM  = texture2D(tex, fragPos.xy).xyz;
/*---------------------------------------------------------*/
	vec3 luma = vec3(0.299, 0.587, 0.114);
	float lumaNW = dot(rgbNW, luma);
	float lumaNE = dot(rgbNE, luma);
	float lumaSW = dot(rgbSW, luma);
	float lumaSE = dot(rgbSE, luma);
	float lumaM  = dot(rgbM,  luma);
/*---------------------------------------------------------*/
	float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
	float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
/*---------------------------------------------------------*/
	vec2 dir;
	dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
	dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));
/*---------------------------------------------------------*/
	float dirReduce = max(
		(lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * FXAA_REDUCE_MUL),
		FXAA_REDUCE_MIN);
	float rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);
	dir = min(vec2(FXAA_SPAN_MAX, FXAA_SPAN_MAX),
		max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX),
		dir * rcpDirMin)) * texel;
/*--------------------------------------------------------*/
	vec3 rgbA = (1.0 / 2.0) * (
		texture2D(tex, fragPos.xy + dir * (1.0 / 3.0 - 0.5)).xyz +
		texture2D(tex, fragPos.xy + dir * (2.0 / 3.0 - 0.5)).xyz);
	vec3 rgbB = rgbA * (1.0 / 2.0) + (1.0 / 4.0) * (
		texture2D(tex, fragPos.xy + dir * (0.0 / 3.0 - 0.5)).xyz +
		texture2D(tex, fragPos.xy + dir * (3.0 / 3.0 - 0.5)).xyz);
	float lumaB = dot(rgbB, luma);
	vec4 ret;
	ret.xyz = ((lumaB < lumaMin) || (lumaB > lumaMax)) ? rgbA : rgbB;
	ret.w = 1.0;
	return ret;
}

void main()
{
	gl_FragColor = FXAA(gm_BaseTexture, v_vFragPos, u_vTexelPS);
}