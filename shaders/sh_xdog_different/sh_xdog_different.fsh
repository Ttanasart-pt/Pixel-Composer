varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D g1;
uniform sampler2D g2;
uniform float gamma;

void main() {
	vec4 s1 = texture2D(g1, v_vTexcoord);
	vec4 s2 = texture2D(g2, v_vTexcoord);
	
	gl_FragColor   = abs(s1 - s2 * gamma);
	gl_FragColor.a = 1.;
}

