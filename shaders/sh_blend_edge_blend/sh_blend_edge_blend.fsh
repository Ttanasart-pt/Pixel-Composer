varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  edge;

uniform sampler2D mask;

void main() {
	float msk = texture2D( mask, v_vTexcoord ).r;
	vec4  cur = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4  off;
	
	if(edge == 0) {
		off = texture2D( gm_BaseTexture, fract(v_vTexcoord + vec2(0.5, 0.5)) );
		
	} else if(edge == 1) {
		off = texture2D( gm_BaseTexture, fract(v_vTexcoord + vec2(0.5, 0.0)) );
		
	} else if(edge == 2) {
		off = texture2D( gm_BaseTexture, fract(v_vTexcoord + vec2(0.0, 0.5)) );
		
	}
	
	gl_FragColor = mix(off, cur, msk);
}
