varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   axis;

void main() {
	vec2 tx = 1. / dimension;
	
	if(axis == 0) {
		float s00 = texture2D(gm_BaseTexture, v_vTexcoord + vec2(-tx.x, -tx.y )).r;
		float s02 = texture2D(gm_BaseTexture, v_vTexcoord + vec2( tx.x, -tx.y )).r;
		
		float s10 = texture2D(gm_BaseTexture, v_vTexcoord + vec2(-tx.x,    0. )).r;
		float s12 = texture2D(gm_BaseTexture, v_vTexcoord + vec2( tx.x,    0. )).r;
		
		float s20 = texture2D(gm_BaseTexture, v_vTexcoord + vec2(-tx.x,  tx.y )).r;
		float s22 = texture2D(gm_BaseTexture, v_vTexcoord + vec2( tx.x,  tx.y )).r;
		
		float sobel = 1. * s00 + -1. * s02 +
		              2. * s10 + -2. * s12 + 
		              1. * s20 + -1. * s22;
		
		gl_FragColor = vec4(sobel, sobel, sobel, 1.);
		
	} else {
		float s00 = texture2D(gm_BaseTexture, v_vTexcoord + vec2(-tx.x, -tx.y )).r;
		float s01 = texture2D(gm_BaseTexture, v_vTexcoord + vec2(   0., -tx.y )).r;
		float s02 = texture2D(gm_BaseTexture, v_vTexcoord + vec2( tx.x, -tx.y )).r;
		
		float s20 = texture2D(gm_BaseTexture, v_vTexcoord + vec2(-tx.x,  tx.y )).r;
		float s21 = texture2D(gm_BaseTexture, v_vTexcoord + vec2(   0.,  tx.y )).r;
		float s22 = texture2D(gm_BaseTexture, v_vTexcoord + vec2( tx.x,  tx.y )).r;
		
		float sobel =  1. * s00 +  2. * s01 +  1. * s02 +
		              -1. * s20 + -2. * s21 + -1. * s22;
		
		gl_FragColor = vec4(sobel, sobel, sobel, 1.);
		
	}
	
}