//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 center;
uniform vec2 dimension;
uniform float strength;
uniform int sampleMode;

#define ITERATION 64.

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
	vec2 pxPos = v_vTexcoord * dimension;
	vec2 pxCen = center * dimension;
	vec2 vecPc  = pxPos - pxCen;
	
	float angle = atan(vecPc.y, vecPc.x);
	float dist  = length(vecPc);
	vec4 clr = vec4(0.);
	float weight = 0.;
	
	for(float i = -strength; i <= strength; i++) {
		float ang = angle + i / 100.;
		vec4 col = sampleTexture((pxCen + vec2(cos(ang), sin(ang)) * dist) / dimension);
		
		clr += col;
		weight += col.a;
	}
	
    gl_FragColor = clr / weight;
}
