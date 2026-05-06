varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	gl_FragData[0] = vec4(-9999999., -9999999., -9999999., 0.);
	gl_FragData[1] = vec4(-9999999., 0., 0., 0.);
}