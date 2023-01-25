//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D backg;
uniform sampler2D scene;
uniform vec2 scnDimension;
uniform vec2 camDimension;
uniform vec2 position;
uniform float zoom;
uniform float blur;
uniform int sampleMode;

vec4 sampleTexture(sampler2D samp, vec2 pos) {
	if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
		return texture2D(samp, pos);
	
	if(sampleMode == 0) 
		return vec4(0.);
	if(sampleMode == 1) 
		return texture2D(samp, clamp(pos, 0., 1.));
	if(sampleMode == 2) 
		return texture2D(samp, fract(pos));
	
	return vec4(0.);
}

void main() {
	vec2 pos = position + (v_vTexcoord - vec2(.5)) * (camDimension / scnDimension) * zoom;
    vec4 _col0 = sampleTexture( scene, pos );
	vec4 _col1 = sampleTexture( backg, pos );
    
	float al = _col0.a + _col1.a * (1. - _col0.a);
	vec4 res = ((_col0 * _col0.a) + (_col1 * _col1.a * (1. - _col0.a))) / al;
	res.a = al;
	
    gl_FragColor = res;
}
