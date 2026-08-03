varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D mask;

void main() {
	vec4 m = texture2D(mask, v_vTexcoord);
	vec4 s = texture2D(gm_BaseTexture, v_vTexcoord);
	
	s.a *= m.a;
	
	gl_FragColor = s;
}