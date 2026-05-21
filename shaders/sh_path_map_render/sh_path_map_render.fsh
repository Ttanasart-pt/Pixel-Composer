varying vec2 v_vTexcoord;

uniform vec2 uvP;
uniform vec2 uvS;

void main() {
	gl_FragColor = texture2D(gm_BaseTexture, fract((v_vTexcoord - uvP) * uvS));
}