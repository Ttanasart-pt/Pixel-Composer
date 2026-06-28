varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int invert;
uniform int alpha;

void main() {
	vec4  c = texture2D( gm_BaseTexture, v_vTexcoord );
	float m = alpha == 1? c.a : (c.r + c.g + c.b) / 3.;
	if(invert == 1) m = 1. - m;
	
    gl_FragColor = alpha == 0? vec4(m, m, m, c.a) : vec4(1., 1., 1., m);
}
