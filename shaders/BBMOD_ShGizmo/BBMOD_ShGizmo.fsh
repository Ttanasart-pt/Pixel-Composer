// FIXME: Temporary fix!
precision highp float;

varying vec3 v_vNormal;
varying vec2 v_vTexCoord;

#define X_GAMMA 2.2

/// @desc Converts gamma space color to linear space.
vec3 xGammaToLinear(vec3 rgb)
{
	return pow(rgb, vec3(X_GAMMA));
}

/// @desc Converts linear space color to gamma space.
vec3 xLinearToGamma(vec3 rgb)
{
	return pow(rgb, vec3(1.0 / X_GAMMA));
}

/// @desc Gets color's luminance.
float xLuminance(vec3 rgb)
{
	return (0.2126 * rgb.r + 0.7152 * rgb.g + 0.0722 * rgb.b);
}

void GammaCorrect()
{
	gl_FragColor.rgb = xLinearToGamma(gl_FragColor.rgb);
}

void main()
{
	vec3 base = xGammaToLinear(texture2D(gm_BaseTexture, v_vTexCoord).rgb);
	vec3 N = normalize(v_vNormal);
	vec3 L = vec3(0.0, 0.0, -1.0);
	float light = mix(0.25, 1.0, max(dot(N, L), 0.0));
	gl_FragColor.rgb = base * light;
	gl_FragColor.a = 1.0;
	GammaCorrect();
}
