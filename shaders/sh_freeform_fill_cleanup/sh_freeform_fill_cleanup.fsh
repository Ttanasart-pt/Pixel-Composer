varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

void main() {
	vec2 tx = 1. / dimension;
	
    gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
	if(gl_FragColor == v_vColour) return;
	
	float chk = 0.;
	
	if(texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x, 0.) ) == v_vColour) chk++;
	if(texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x, 0.) ) == v_vColour) chk++;
	if(texture2D( gm_BaseTexture, v_vTexcoord + vec2(0.,  tx.y) ) == v_vColour) chk++;
	if(texture2D( gm_BaseTexture, v_vTexcoord + vec2(0., -tx.y) ) == v_vColour) chk++;
	
	if(chk >= 3.) gl_FragColor = v_vColour;
}
