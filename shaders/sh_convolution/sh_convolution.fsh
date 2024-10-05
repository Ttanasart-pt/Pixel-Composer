//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int   size;
uniform vec2  dimension;
uniform float kernel[256];
uniform int   sampleMode;
uniform int   normalized;

vec4 sampleTexture(vec2 pos) {
	if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
		return texture2D(gm_BaseTexture, pos);
	
	if(sampleMode == 0) 
		return vec4(0.);
		
	else if(sampleMode == 1) 
		return texture2D(gm_BaseTexture, clamp(pos, 0., 1.));
		
	else if(sampleMode == 2) 
		return texture2D(gm_BaseTexture, fract(pos));
	
	else if(sampleMode == 3) 
		return vec4(vec3(0.), 1.);
		
	return vec4(0.);
}

void main() {
	vec2  tex = 1. / dimension;
	float sum = 1.;
	
	if(normalized == 1) {
		sum = 0.;
		int amo = size * size;
		for(int i = 0; i < amo; i++) sum += kernel[i];
	}
	
	float st = -(float(size) - 1.) / 2.;
	vec4  c  = vec4(0.);
	
	for(int i = 0; i < size; i++)
	for(int j = 0; j < size; j++) {
		int  index = i * size + j;
		vec2 px    = v_vTexcoord + vec2((float(j) + st) * tex.x, (float(i) + st) * tex.y);
		
		c += kernel[index] * sampleTexture(px) / sum;
	}
	
    gl_FragColor = c;
}
