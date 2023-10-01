varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D texture;

void main() {
	gl_FragColor = texture2D( texture, v_vTexcoord );
	//gl_FragColor = vec4(1.);
}
