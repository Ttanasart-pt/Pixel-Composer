//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

void main() {
	vec2 texel = 1. / dimension;
	
	vec4 c  = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 c0 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(texel.x, 0.) );
	vec4 c1 = texture2D( gm_BaseTexture, v_vTexcoord - vec2(texel.x, 0.) );
	vec4 c2 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(0., texel.y) );
	vec4 c3 = texture2D( gm_BaseTexture, v_vTexcoord - vec2(0., texel.y) );
	
	int _c  = c .a > 0.? 1 : 0;
	int _c0 = c0.a > 0.? 1 : 0;
	int _c1 = c1.a > 0.? 1 : 0;
	int _c2 = c2.a > 0.? 1 : 0;
	int _c3 = c3.a > 0.? 1 : 0;
	
	if(_c == 0 && _c0 + _c1 + _c2 + _c3 >= 2) {
		gl_FragColor   = ((c0 * c0.a) + (c1 * c1.a) + (c2 * c2.a) + (c3 * c3.a)) / (c0.a + c1.a + c2.a + c3.a);
		gl_FragColor.a = 1.;
	} else 
		gl_FragColor = c;
}
