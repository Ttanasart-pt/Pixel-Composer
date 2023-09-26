//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform float amount;

void main() {
	vec2 tx = 1. / dimension;
	gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
	
	if(amount > 0.) {
	    if(gl_FragColor.a > 0.) {
			gl_FragColor = vec4(1.);
			return;
		}
		
		for( float i = 0.; i < amount; i++ ) {
			vec2 _tx0 = v_vTexcoord + vec2(  tx.x, 0. ) * i;
			vec2 _tx1 = v_vTexcoord + vec2( -tx.x, 0. ) * i;
			vec2 _tx2 = v_vTexcoord + vec2( 0.,  tx.y ) * i;
			vec2 _tx3 = v_vTexcoord + vec2( 0., -tx.y ) * i;
		
			vec4 _sm0 = texture2D( gm_BaseTexture, _tx0 );
			if(_sm0.a > 0.) { gl_FragColor = vec4(1.); return; }
		
			vec4 _sm1 = texture2D( gm_BaseTexture, _tx1 );
			if(_sm1.a > 0.) { gl_FragColor = vec4(1.); return; }
		
			vec4 _sm2 = texture2D( gm_BaseTexture, _tx2 );
			if(_sm2.a > 0.) { gl_FragColor = vec4(1.); return; }
		
			vec4 _sm3 = texture2D( gm_BaseTexture, _tx3 );
			if(_sm3.a > 0.) { gl_FragColor = vec4(1.); return; }
		}
		
		gl_FragColor = vec4(0.);
	} else {
		if(gl_FragColor == vec4(0.)) return;
		
		for( float i = 0.; i < abs(amount); i++ ) {
			vec2 _tx0 = v_vTexcoord + vec2(  tx.x, 0. ) * i;
			vec2 _tx1 = v_vTexcoord + vec2( -tx.x, 0. ) * i;
			vec2 _tx2 = v_vTexcoord + vec2( 0.,  tx.y ) * i;
			vec2 _tx3 = v_vTexcoord + vec2( 0., -tx.y ) * i;
		
			vec4 _sm0 = texture2D( gm_BaseTexture, _tx0 );
			if(_sm0.a == 0.) { gl_FragColor = vec4(0.); return; }
		
			vec4 _sm1 = texture2D( gm_BaseTexture, _tx1 );
			if(_sm1.a == 0.) { gl_FragColor = vec4(0.); return; }
		
			vec4 _sm2 = texture2D( gm_BaseTexture, _tx2 );
			if(_sm2.a == 0.) { gl_FragColor = vec4(0.); return; }
		
			vec4 _sm3 = texture2D( gm_BaseTexture, _tx3 );
			if(_sm3.a == 0.) { gl_FragColor = vec4(0.); return; }
		}
		
		gl_FragColor = vec4(1.);
	}
}
