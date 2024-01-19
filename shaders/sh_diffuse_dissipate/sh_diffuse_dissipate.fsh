varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float dissipation;

void main() {
	vec2 tx = 1. / dimension;
	
	vec4 f0 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x, -tx.y) );
	vec4 f1 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(   0., -tx.y) );
	vec4 f2 = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x, -tx.y) );
	
	vec4 f3 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x,    0.) );
	vec4 f4 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(   0.,    0.) );
	vec4 f5 = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x,    0.) );
	
	vec4 f6 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x,  tx.y) );
	vec4 f7 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(   0.,  tx.y) );
	vec4 f8 = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x,  tx.y) );
	
    vec4 clr = (f0 + f1 + f2 + f3 + f4 + f5 + f6 + f7 + f8) / 9.;
    gl_FragColor = vec4(clr.rgb * dissipation, clr.a);
}
