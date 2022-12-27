//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D samR, samG, samB;

void main() {
    vec4 _r = texture2D( samR, v_vTexcoord );
    vec4 _g = texture2D( samG, v_vTexcoord );
    vec4 _b = texture2D( samB, v_vTexcoord );
	
	float r = (_r[0] + _r[1] + _r[2]) / 3.;
	float g = (_g[0] + _g[1] + _g[2]) / 3.;
	float b = (_b[0] + _b[1] + _b[2]) / 3.;
	
	gl_FragColor = vec4(r, g, b, 1.);
}
