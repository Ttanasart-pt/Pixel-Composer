varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 sm = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = vec4(0.);
	if(sm.a > 0.) gl_FragColor = vec4(0., 0., 0., 1.);
}