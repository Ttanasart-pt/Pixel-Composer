varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 scale;

void main() {
	gl_FragColor = texture2D(gm_BaseTexture, fract(v_vTexcoord * scale));
}