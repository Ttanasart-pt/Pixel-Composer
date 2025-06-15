varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int    useMask;
uniform sampler2D mask;

void main() {
    vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
    vec2 p = (c.xy + c.zw) / 2.;
    
	if(c.rgb == vec3(0.)) {
		gl_FragColor = vec4(0.);
		return;
	}
	
	if(useMask == 1) {
		vec4  m   = texture2D( mask, p );
		float sel = (m.r + m.g + m.b) / 3. * m.a;
		if(sel == 0.) { gl_FragColor = vec4(0.); return; }
	}
	
	gl_FragColor = vec4( c.xy, 0., 1. );
}
