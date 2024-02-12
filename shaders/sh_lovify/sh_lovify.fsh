varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define SRGB_TO_LINEAR(c) pow((c), vec3(2.2))
#define LINEAR_TO_SRGB(c) pow((c), vec3(1.0 / 2.2))
#define SRGB(r, g, b) SRGB_TO_LINEAR(vec3(r, g, b) / 255.0)

void main() {
	vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
	
	vec3 COLOR0 = SRGB(252., 3., 111.);
	vec3 COLOR1 = SRGB(190., 3., 252.);
	
	float t = length(v_vTexcoord) / sqrt(2.);
          t = smoothstep(0.0, 1.0, clamp(t, 0.0, 1.0));
	
    vec3 color = mix(COLOR0, COLOR1, t);
	     color = LINEAR_TO_SRGB(color);
	vec4 b = vec4(color, 1.);
	
	float lum  = dot(c.rgb, vec3(0.2126, 0.7152, 0.0722));
	vec4 blend = lum > 0.5? (1. - (1. - 2. * (b - 0.5)) * (1. - c)) : ((2. * b) * c);
	     blend = 0.5 + (blend * 1.75 - 0.5) * 0.66;
		 
    gl_FragColor = blend;
}