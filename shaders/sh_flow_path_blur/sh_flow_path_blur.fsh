varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  tile;

vec4 samp(vec2 shft) {
	vec2 pos = tile == 1? fract(fract(v_vTexcoord + shft) + 1.) : v_vTexcoord + shft;
	return texture2D( gm_BaseTexture, pos);
}

void main() {
	vec2 tx = 1. / dimension;
	
	vec4 s0 = samp( vec2(-tx.x, -tx.y) );
	vec4 s1 = samp( vec2(   0., -tx.y) );
	vec4 s2 = samp( vec2( tx.x, -tx.y) );
	
	vec4 s3 = samp( vec2(-tx.x,    0.) );
	vec4 s4 = samp( vec2(   0.,    0.) );
	vec4 s5 = samp( vec2( tx.x,    0.) );
	
	vec4 s6 = samp( vec2(-tx.x,  tx.y) );
	vec4 s7 = samp( vec2(   0.,  tx.y) );
	vec4 s8 = samp( vec2( tx.x,  tx.y) );
	
	gl_FragColor = ( s0 + s1 + s2 + 
	                 s3 + s4 + s5 + 
	                 s6 + s7 + s8 ) / 9.;
	
}