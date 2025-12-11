varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float intensity;

void main() {
	gl_FragColor = texture2D(gm_BaseTexture, v_vTexcoord) * intensity;
}