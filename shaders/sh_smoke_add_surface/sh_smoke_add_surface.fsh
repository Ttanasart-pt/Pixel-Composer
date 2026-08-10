varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4  sam = texture2D(gm_BaseTexture, v_vTexcoord);
	float den = (sam.r + sam.g + sam.b) / 3. * sam.a;
	
	gl_FragColor = vec4(1., 1., 1., den);
}