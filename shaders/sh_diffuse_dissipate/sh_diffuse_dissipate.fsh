varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;

uniform vec2      dissipation;
uniform int       dissipationUseSurf;
uniform sampler2D dissipationSurf;

void main() {
	#region params
		float dis = dissipation.x;
		if(dissipationUseSurf == 1) {
			vec4 _vMap = texture2D( dissipationSurf, v_vTexcoord );
			dis = mix(dissipation.x, dissipation.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		dis = 1. - dis;
	#endregion
	
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
    gl_FragColor = vec4(clr.rgb * clr.a * dis, 1.);
}
