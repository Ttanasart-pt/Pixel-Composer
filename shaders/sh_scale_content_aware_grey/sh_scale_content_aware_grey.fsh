varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4  c = texture2D(gm_BaseTexture, v_vTexcoord);
	float g = (c.r + c.g + c.b) / 3. * c.a;
	gl_FragColor = vec4(g,g,g,1.);
}