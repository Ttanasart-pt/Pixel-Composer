varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4  sm = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
	float gr = (sm.x + sm.y + sm.z) / 3. * sm.a;
	gl_FragColor = vec4(gr, gr, gr, 1.);
}