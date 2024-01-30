varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define ITERATION 8.

uniform vec2  dimension;

vec4 sample ( vec2 position ) {
	if(position.x < 0. || position.y < 0. || position.x > 1. || position.y > 1.) return vec4(1., 1., 1., 1.);
	return texture2D( gm_BaseTexture, position );
}

void main() {
	vec2 tx = 1. / dimension;
    gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
	
	if(gl_FragColor.b == 1.) return;
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec4 s = sample( v_vTexcoord + vec2(tx.x * i, 0) );
		
		if(s.a == 0.) break;
		if(s.b == 0.) continue;
		
		gl_FragColor.b = 1.;
		return;
	}
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec4 s = sample( v_vTexcoord - vec2(tx.x * i, 0) );
		
		if(s.a == 0.) break;
		if(s.b == 0.) continue;
		
		gl_FragColor.b = 1.;
		return;
	}
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec4 s = sample( v_vTexcoord + vec2(0, tx.y * i) );
		
		if(s.a == 0.) break;
		if(s.b == 0.) continue;
		
		gl_FragColor.b = 1.;
		return;
	}
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec4 s = sample( v_vTexcoord - vec2(0, tx.y * i) );
		
		if(s.a == 0.) break;
		if(s.b == 0.) continue;
		
		gl_FragColor.b = 1.;
		return;
	}
}
