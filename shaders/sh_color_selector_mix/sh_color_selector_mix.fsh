varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int  mode;
uniform vec4 from;
uniform vec4 to;

void main() {
	float _x = v_vTexcoord.x;
	vec3 clr = mix(from.rgb, to.rgb, _x);
	
	gl_FragColor = vec4(clr, 1.);
}