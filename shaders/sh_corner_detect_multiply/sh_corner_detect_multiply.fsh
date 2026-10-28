varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D s0;
uniform sampler2D s1;

void main() {
	gl_FragColor = v_vColour * texture2D(s0, v_vTexcoord) * texture2D(s1, v_vTexcoord);
}