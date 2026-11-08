varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D domain;

void main() {
	vec4 dom = v_vColour * texture2D(domain, v_vTexcoord);
	dom.z = 0.;
	
	gl_FragColor = dom;
}