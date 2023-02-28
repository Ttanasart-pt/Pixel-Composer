//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float dimension;

void main() {
	vec2 pos = v_vTexcoord * dimension;
	vec2 st  = floor(pos / 2.) * 2.;
	
    vec4 c0 = texture2D( gm_BaseTexture, (st + vec2(0., 0.)) / dimension );
    vec4 c1 = texture2D( gm_BaseTexture, (st + vec2(1., 0.)) / dimension );
    vec4 c2 = texture2D( gm_BaseTexture, (st + vec2(0., 1.)) / dimension );
    vec4 c3 = texture2D( gm_BaseTexture, (st + vec2(1., 1.)) / dimension );
	
	gl_FragColor = (c0 + c1 + c2 + c3) / (c0.a + c1.a + c2.a + c3.a);
}
