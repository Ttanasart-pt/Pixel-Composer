//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int useA;
uniform int mode;
uniform sampler2D samR, samG, samB, samA;

float samC(vec4 col, int ch) {
	if(mode == 0)
		return (col[0] + col[1] + col[2]) / 3.;
	
	return col[ch];
}

void main() {
    vec4 _r = texture2D( samR, v_vTexcoord );
    vec4 _g = texture2D( samG, v_vTexcoord );
    vec4 _b = texture2D( samB, v_vTexcoord );
    
	float r = samC(_r, 0);
	float g = samC(_g, 1);
	float b = samC(_b, 2);
	float a = 1.;
	
	if(useA == 1) {
		vec4 _a = texture2D( samA, v_vTexcoord );
		a = samC(_a, 3);
	}
	
	gl_FragColor = vec4(r, g, b, a);
}
