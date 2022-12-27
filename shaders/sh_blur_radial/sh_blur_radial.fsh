//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float strength;
uniform vec2 center;
uniform int sampleMode;

const float nsamples = 32.;

vec4 sampleTexture(vec2 pos) {
	if(pos.x > 0. && pos.y > 0. && pos.x < 1. && pos.y < 1.)
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
    vec2 uv = v_vTexcoord - center;
	float scale_factor = strength * (1. / (nsamples - 1.));
	vec4 color = vec4(0.0);
    
    for(float i = 0.; i < nsamples; i++) {
        float scale = 1.0 + (i * scale_factor);
		vec2 pos = uv * scale + center;
		color += sampleTexture(pos);
    }
    
    color /= nsamples;
    
	gl_FragColor = color;
}

