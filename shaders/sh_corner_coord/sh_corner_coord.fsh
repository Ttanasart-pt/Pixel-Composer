varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 cc = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = (cc.r + cc.g + cc.b) * cc.a / 3. > .5? vec4(v_vTexcoord, 0., 1.) : vec4(0.);
}