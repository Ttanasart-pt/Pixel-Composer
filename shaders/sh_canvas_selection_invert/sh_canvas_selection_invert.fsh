varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 mask = texture2D(gm_BaseTexture, v_vTexcoord);
	mask = 1. - mask;
	gl_FragColor = mask;
}