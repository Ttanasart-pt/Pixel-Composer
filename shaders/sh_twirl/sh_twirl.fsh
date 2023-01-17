//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 center;
uniform float strength;
uniform float radius;
uniform int sampleMode;

vec4 sampleTexture(vec2 pos) {
	if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
		return texture2D(gm_BaseTexture, pos);
	
	if(sampleMode == 0) 
		return vec4(0.);
	if(sampleMode == 1) 
		return texture2D(gm_BaseTexture, clamp(pos, 0., 1.));
	if(sampleMode == 2) 
		return texture2D(gm_BaseTexture, fract(pos));
	
	return vec4(0.);
}

void main() {
	vec2 pixelPos = v_vTexcoord * dimension;
	vec2 to		= pixelPos - center;
	float dis	= distance(center, pixelPos);
	float eff	= 1. - clamp(dis / radius, 0., 1.);
	float ang	= atan(to.y, to.x) + eff * strength;
	
	vec2 tex = center + vec2(cos(ang), sin(ang)) * distance(center, pixelPos);
    gl_FragColor = sampleTexture( tex / dimension );
}
