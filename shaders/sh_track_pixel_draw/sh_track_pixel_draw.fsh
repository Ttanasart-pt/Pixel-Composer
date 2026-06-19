varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 val = texture2D(gm_BaseTexture, v_vTexcoord);
	// gl_FragColor = vec4((val.r + val.g + val.b) / 3. * val.a, 1., 1., 1.);
	gl_FragColor = val;
}