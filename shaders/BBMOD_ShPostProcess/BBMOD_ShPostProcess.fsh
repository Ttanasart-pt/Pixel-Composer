// FIXME: Temporary fix!
precision highp float;

varying vec2 v_vTexCoord;

uniform sampler2D u_texLut;    // Color grading LUT
uniform vec2 u_vTexel;         // 1/ScreenWidth, 1/ScreenHeight
uniform vec3 u_vOffset;        // Chromatic aberration offset for each channel
uniform float u_fDistortion;   // The strength of the chromatic aberration effect
uniform float u_fGrayscale;    // The strength of the grayscale effect
uniform float u_fVignette;     // The strength of the vignette effect
uniform vec3 u_vVignetteColor; // The color of the vignette effect

/// @param color The original RGB color.
/// @param lut Texture of color-grading lookup table (256x16).
/// Needs to have interpolation enabled!
vec3 ColorGrade(vec3 color, sampler2D lut)
{
	// Fixes selecting wrong mips on HTML5.
	const float bias = -5.0;

	const vec2 texel = 1.0 / vec2(256.0, 16.0);

	float x1 = floor(color.r * 15.0);
	float y1 = floor(color.g * 15.0);
	float z1 = floor(color.b * 15.0) * 16.0;

	float x2 = ceil(color.r * 15.0);
	float y2 = ceil(color.g * 15.0);
	float z2 = ceil(color.b * 15.0) * 16.0;

	vec2 uv1 = vec2(z1 + x1, y1) * texel;
	vec2 uv2 = vec2(z2 + x2, y2) * texel;

	uv1 += 0.5 * texel;
	uv2 += 0.5 * texel;

	vec3 color1 = texture2D(lut, uv1, bias).rgb;
	vec3 color2 = texture2D(lut, uv2, bias).rgb;

	return vec3(
		mix(color1.r, color2.r, fract(color.r * 15.0)),
		mix(color1.g, color2.g, fract(color.g * 15.0)),
		mix(color1.b, color2.b, fract(color.b * 15.0)));
}

float Luminance(vec3 color)
{
	const vec3 weights = vec3(0.2125, 0.7154, 0.0721);
	return dot(color, weights);
}

//#pragma include("ChromaticAberration.xsh")
/// @param direction  Direction of distortion.
/// @param distortion Per-channel distortion factor.
/// @source http://john-chapman-graphics.blogspot.cz/2013/02/pseudo-lens-flare.html
vec3 xChromaticAberration(
	sampler2D tex,
	vec2 uv,
	vec2 direction,
	vec3 distortion)
{
	return vec3(
		texture2D(tex, uv + direction * distortion.r).r
			+ texture2D(tex, uv + direction * distortion.r * (1.0 / 4.0)).r
			+ texture2D(tex, uv + direction * distortion.r * (2.0 / 4.0)).r
			+ texture2D(tex, uv + direction * distortion.r * (3.0 / 4.0)).r,
		texture2D(tex, uv + direction * distortion.g).g
			+ texture2D(tex, uv + direction * distortion.g * (1.0 / 4.0)).g
			+ texture2D(tex, uv + direction * distortion.g * (2.0 / 4.0)).g
			+ texture2D(tex, uv + direction * distortion.g * (3.0 / 4.0)).g,
		texture2D(tex, uv + direction * distortion.b).b
			+ texture2D(tex, uv + direction * distortion.b * (1.0 / 4.0)).b
			+ texture2D(tex, uv + direction * distortion.b * (2.0 / 4.0)).b
			+ texture2D(tex, uv + direction * distortion.b * (3.0 / 4.0)).b
	) / 4.0;
}

// include("ChromaticAberration.xsh")

void main()
{
	vec2 vec = 0.5 - v_vTexCoord;
	float vecLen = length(vec);
	vec3 color;

	// Chromatic aberration
	if (u_fDistortion != 0.0)
	{
		vec3 distortion = u_vOffset * u_vTexel.x * u_fDistortion * min(vecLen / 0.5, 1.0);
		color = xChromaticAberration(gm_BaseTexture, v_vTexCoord, normalize(vec), distortion);
	}
	else
	{
		color = texture2D(gm_BaseTexture, v_vTexCoord).rgb;
	}

	// Color grading
#ifndef _YY_GLSLES_
	color = ColorGrade(color, u_texLut);
#endif

	// Grayscale
	if (u_fGrayscale != 0.0)
	{
		color = mix(color, vec3(Luminance(color)), u_fGrayscale);
	}

	// Vignette
	if (u_fVignette != 0.0)
	{
		color = mix(color, u_vVignetteColor, vecLen * vecLen * u_fVignette);
	}

	gl_FragColor.rgb = color;
	gl_FragColor.a = 1.0;
}
