//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int useA;
uniform int mode;
uniform sampler2D samplerR;
uniform sampler2D samplerG;
uniform sampler2D samplerB;
uniform sampler2D samplerA;

float sample(vec4 col, int ch) {
	if(mode == 0) return (col[0] + col[1] + col[2]) / 3.;
	return col[ch];
}

void main() {
    vec4 _r = texture2D( samplerR, v_vTexcoord );
    vec4 _g = texture2D( samplerG, v_vTexcoord );
    vec4 _b = texture2D( samplerB, v_vTexcoord );
    
	float r = sample(_r, 0);
	float g = sample(_g, 1);
	float b = sample(_b, 2);
	float a = 1.;
	
	if(useA == 1) {
		vec4 _a = texture2D( samplerA, v_vTexcoord );
		a = sample(_a, 3);
	}
	
	gl_FragColor = vec4(r, g, b, a);
}
