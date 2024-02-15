varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define ITERATION 2.

uniform sampler2D original;
uniform vec2 dimension;

void main() {
	vec2 tx = 1. / dimension;
	vec4 c  = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 o  = texture2D( original,       v_vTexcoord );
	
	gl_FragColor = c;
	if(c.a == 1.) return;
	
	float minD = ITERATION;
	
	for( float i = 1.; i < ITERATION; i++ ) {
		if(i >= minD) break;
		
		vec2 x = v_vTexcoord + vec2(tx.x * i, 0.);
		if(x.x < 0. || x.y < 0. || x.x > 1. || x.y > 1.) break;
		
		vec4 s = texture2D( gm_BaseTexture, x );
		if(s.a == 0.) continue;
		
		gl_FragColor = s;
		minD = i;
	}
    
	for( float i = 1.; i < ITERATION; i++ ) {
		if(i >= minD) break;
		
		vec2 x = v_vTexcoord - vec2(tx.x * i, 0.);
		if(x.x < 0. || x.y < 0. || x.x > 1. || x.y > 1.) break;
		
		vec4 s = texture2D( gm_BaseTexture, x );
		if(s.a == 0.) continue;
		
		gl_FragColor = s;
		minD = i;
	}
    
	for( float i = 1.; i < ITERATION; i++ ) {
		if(i >= minD) break;
		
		vec2 x = v_vTexcoord + vec2(0., tx.y * i);
		if(x.x < 0. || x.y < 0. || x.x > 1. || x.y > 1.) break;
		
		vec4 s = texture2D( gm_BaseTexture, x );
		if(s.a == 0.) continue;
		
		gl_FragColor = s;
		minD = i;
	}
    
	for( float i = 1.; i < ITERATION; i++ ) {
		if(i >= minD) break;
		
		vec2 x = v_vTexcoord - vec2(0., tx.y * i);
		if(x.x < 0. || x.y < 0. || x.x > 1. || x.y > 1.) break;
		
		vec4 s = texture2D( gm_BaseTexture, x );
		if(s.a == 0.) continue;
		
		gl_FragColor = s;
		minD = i;
	}
}
