varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int invert;

void main() {
	vec4  c = texture2D( gm_BaseTexture, v_vTexcoord );
	float m = (c.r + c.g + c.b) / 3. * c.a;
	if(invert == 1) m = 1. - m;
	
    gl_FragColor = vec4(m, m, m, 1.);
}
