varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4 target;

void main() {
	vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = base;
	if(base == target) gl_FragColor = vec4(0.);
}