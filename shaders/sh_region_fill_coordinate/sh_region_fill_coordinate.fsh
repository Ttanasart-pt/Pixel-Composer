//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define ITERATION 8.

uniform vec2  dimension;
uniform float step;

vec4 less ( vec4 a, vec4 b ) {
	if(b.xy == vec2(0.)) return a;
	if(a.xy == vec2(0.)) return b;
	
	if(a.y < b.y)		return a;
	else if(a.y > b.y)	return b;
	else				return a.x < b.x? a : b;
}

vec4 sample ( vec2 position ) {
	if(position.x < 0. || position.y < 0. || position.x > 1. || position.y > 1.) return vec4(1.);
	return texture2D( gm_BaseTexture, position );
}

void main() {
	vec2 tx = 1. / dimension;
    vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
	gl_FragColor = c;
	
	if(c.a == 0.) return;
	if(c.b == 1.) {
		gl_FragColor = vec4(0.);
		return;
	}
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec4 s = sample( v_vTexcoord + vec2(tx.x * i, 0) );
		if(s.a == 0.) break;
		gl_FragColor = less( gl_FragColor, s );
	}
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec4 s = sample( v_vTexcoord - vec2(tx.x * i, 0) );
		if(s.a == 0.) break;
		gl_FragColor = less( gl_FragColor, s );
	}
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec4 s = sample( v_vTexcoord + vec2(0, tx.y * i) );
		if(s.a == 0.) break;
		gl_FragColor = less( gl_FragColor, s );
	}
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec4 s = sample( v_vTexcoord - vec2(0, tx.y * i) );
		if(s.a == 0.) break;
		gl_FragColor = less( gl_FragColor, s );
	}
}
