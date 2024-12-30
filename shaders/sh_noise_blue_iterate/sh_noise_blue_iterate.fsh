varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 seed;

void main() {
	gl_FragColor = texture2D(gm_BaseTexture, v_vTexcoord);
}