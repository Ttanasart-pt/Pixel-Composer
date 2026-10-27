varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 mask = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
	float vl  = (mask.r + mask.g + mask.g) / 3. * mask.a;
	gl_FragColor = vec4(vec3(step(vl, .5)), 1.);
}