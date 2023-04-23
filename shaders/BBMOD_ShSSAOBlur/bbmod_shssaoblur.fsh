// Size of the SSAO noise texture.
#define BBMOD_SSAO_NOISE_TEXTURE_SIZE 4

varying vec2 v_vTexCoord;

uniform sampler2D u_texDepth;
uniform vec2 u_vTexel; // (1 / screenWidth, 0) for horizontal blur, (0 , 1 / screenHeight) for vertical
uniform float u_fClipFar;

//#pragma include("DepthEncoding.xsh", "glsl")
/// @param d Linearized depth to encode.
/// @return Encoded depth.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
vec3 xEncodeDepth(float d)
{
	const float inv255 = 1.0 / 255.0;
	vec3 enc;
	enc.x = d;
	enc.y = d * 255.0;
	enc.z = enc.y * 255.0;
	enc = fract(enc);
	float temp = enc.z * inv255;
	enc.x -= enc.y * inv255;
	enc.y -= temp;
	enc.z -= temp;
	return enc;
}

/// @param c Encoded depth.
/// @return Docoded linear depth.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
float xDecodeDepth(vec3 c)
{
	const float inv255 = 1.0 / 255.0;
	return c.x + (c.y * inv255) + (c.z * inv255 * inv255);
}
// include("DepthEncoding.xsh")

void main()
{
	gl_FragColor = vec4(0.0);
	float depth = xDecodeDepth(texture2D(u_texDepth, v_vTexCoord).rgb) * u_fClipFar;
	float weightSum = 0.001;
	for (float i = 0.0; i < float(BBMOD_SSAO_NOISE_TEXTURE_SIZE); i += 1.0)
	{
		vec2 uv = v_vTexCoord + u_vTexel * i;
		float sampleDepth = xDecodeDepth(texture2D(u_texDepth, uv).rgb) * u_fClipFar;
		float weight = 1.0 - clamp(abs(depth - sampleDepth) / 2.0, 0.0, 1.0); // TODO: Configurable blur depth range?
		gl_FragColor.rgb += texture2D(gm_BaseTexture, uv).rgb * weight;
		weightSum += weight;
	}
	gl_FragColor.rgb /= weightSum;
	gl_FragColor.a = 1.0;
}
