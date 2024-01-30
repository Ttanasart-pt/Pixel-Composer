varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define ITERATION 8.

uniform vec2 dimension;
uniform sampler2D original;

vec4 sample ( vec2 position ) {
	if(position.x < 0. || position.y < 0. || position.x > 1. || position.y > 1.) return vec4(0.);
	return texture2D( gm_BaseTexture, position );
}

void main() {
	vec2 tx = 1. / dimension;
	vec4 c  = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 o  = texture2D( original,       v_vTexcoord );
	
	gl_FragColor = c;
	if(c.a == 1.) return;
	if(o.a == 0.) return;
    
	float minD = ITERATION;
	
	for( float i = 1.; i < ITERATION; i++ ) {
		if(i >= minD) break;
		
		vec4 s = sample( v_vTexcoord + vec2(tx.x * i, 0.) );
		if(s.a == 0.) continue;
		
		gl_FragColor = s;
		minD = i;
	}
    
	for( float i = 1.; i < ITERATION; i++ ) {
		if(i >= minD) break;
		
		vec4 s = sample( v_vTexcoord - vec2(tx.x * i, 0.) );
		if(s.a == 0.) continue;
		
		gl_FragColor = s;
		minD = i;
	}
    
	for( float i = 1.; i < ITERATION; i++ ) {
		if(i >= minD) break;
		
		vec4 s = sample( v_vTexcoord + vec2(0., tx.y * i) );
		if(s.a == 0.) continue;
		
		gl_FragColor = s;
		minD = i;
	}
    
	for( float i = 1.; i < ITERATION; i++ ) {
		if(i >= minD) break;
		
		vec4 s = sample( v_vTexcoord - vec2(0., tx.y * i) );
		if(s.a == 0.) continue;
		
		gl_FragColor = s;
		minD = i;
	}
}
