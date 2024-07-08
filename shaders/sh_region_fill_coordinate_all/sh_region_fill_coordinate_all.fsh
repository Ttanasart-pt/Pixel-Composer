varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define ITERATION 4.

uniform sampler2D base;
uniform vec2  dimension;

vec2 minn( in vec2 a, in vec2 b) {
		 if(a.y < b.y) return a;
	else if(a.y > b.y) return b;
	
	return (a.x < b.x)? a : b;
}

vec2 maxx( in vec2 a, in vec2 b) {
		 if(a.y < b.y) return b;
	else if(a.y > b.y) return a;
	
	return (a.x < b.x)? b : a;
}

void main() {
	vec2 tx = 1. / dimension;
    vec4 c  = texture2D( gm_BaseTexture, v_vTexcoord );
    vec4 ba = texture2D( base, v_vTexcoord );
	
	gl_FragColor = c;
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec2 x = v_vTexcoord + vec2(tx.x * i, 0);
		if(x.x < 0. || x.y < 0. || x.x > 1. || x.y > 1.) break;
		
		vec4 b = texture2D( base, x );
		if(b != ba) break;
		
		vec4 s = texture2D( gm_BaseTexture, x );
		gl_FragColor.xy = minn( gl_FragColor.xy, s.xy );
		gl_FragColor.zw = maxx( gl_FragColor.zw, s.zw );
	}
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec2 x = v_vTexcoord - vec2(tx.x * i, 0);
		if(x.x < 0. || x.y < 0. || x.x > 1. || x.y > 1.) break;
		
		vec4 b = texture2D( base, x );
		if(b != ba) break;
		
		vec4 s = texture2D( gm_BaseTexture, x );
		gl_FragColor.xy = min( gl_FragColor.xy, s.xy );
		gl_FragColor.zw = max( gl_FragColor.zw, s.zw );
	}
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec2 x = v_vTexcoord + vec2(0, tx.y * i);
		if(x.x < 0. || x.y < 0. || x.x > 1. || x.y > 1.) break;
		
		vec4 b = texture2D( base, x );
		if(b != ba) break;
		
		vec4 s = texture2D( gm_BaseTexture, x );
		gl_FragColor.xy = min( gl_FragColor.xy, s.xy );
		gl_FragColor.zw = max( gl_FragColor.zw, s.zw );
	}
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec2 x = v_vTexcoord - vec2(0, tx.y * i);
		if(x.x < 0. || x.y < 0. || x.x > 1. || x.y > 1.) break;
		
		vec4 b = texture2D( base, x );
		if(b != ba) break;
		
		vec4 s = texture2D( gm_BaseTexture, x );
		gl_FragColor.xy = min( gl_FragColor.xy, s.xy );
		gl_FragColor.zw = max( gl_FragColor.zw, s.zw );
	}
}
