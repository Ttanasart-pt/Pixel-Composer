varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 mask = texture2D(gm_BaseTexture, v_vTexcoord);
	vec4 res  = (mask.r + mask.g + mask.b) / 3. * mask.a > .5? vec4(1., 0., 0., 1.) : vec4(0., 0., 0., 0.);
	gl_FragColor = res;
}