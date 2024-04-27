varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   axis;
uniform float iteration;

void main() {
	vec2 tx  = 1. / dimension;
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
    gl_FragColor = col;
	
	if(col.a > 0.) return;
	
	float amo;
	vec2 _axs;
	vec4 ss;
	
	if(axis == 0) {
		amo = dimension.x;
		_axs = vec2(tx.x, 0.);
		
	} else {
		amo = dimension.y;
		_axs = vec2(0., tx.y);
		
	}
		
	for(float i = 1.; i < amo; i++) {
		ss = texture2D( gm_BaseTexture, v_vTexcoord + _axs * i);
		if(ss.a > 0.) { col = ss; break; }
		
		ss = texture2D( gm_BaseTexture, v_vTexcoord - _axs * i);
		if(ss.a > 0.) { col = ss; break; }
	}
	
	gl_FragColor = col;
}
