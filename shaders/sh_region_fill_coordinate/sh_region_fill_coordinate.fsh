varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define ITERATION 4.

uniform sampler2D base;
uniform vec2  dimension;

vec2 less ( vec2 a, vec2 b ) { #region
	if(b == vec2(0.)) return a;
	if(a == vec2(0.)) return b;
	
	if(a.y < b.y)		return a;
	else if(a.y > b.y)	return b;
	else				return a.x < b.x? a : b;
} #endregion

vec2 more ( vec2 a, vec2 b ) { #region
	if(b == vec2(0.)) return a;
	if(a == vec2(0.)) return b;
	
	if(a.y > b.y)		return a;
	else if(a.y < b.y)	return b;
	else				return a.x > b.x? a : b;
} #endregion

void main() {
	vec2 tx = 1. / dimension;
    vec4 c  = texture2D( gm_BaseTexture, v_vTexcoord );
    vec4 b  = texture2D( base, v_vTexcoord );
	
	gl_FragColor = vec4(0.);
	
	if(b.a == 0.) return;
	
	gl_FragColor = c;
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec2 x = v_vTexcoord + vec2(tx.x * i, 0);
		if(x.x < 0. || x.y < 0. || x.x > 1. || x.y > 1.) break;
		
		vec4 s = texture2D( gm_BaseTexture, x );
		vec4 b = texture2D( base, x );
		
		if(b.a == 0.) break;
		
		gl_FragColor.xy = less( gl_FragColor.xy, s.xy );
		gl_FragColor.zw = more( gl_FragColor.zw, s.zw );
	}
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec2 x = v_vTexcoord - vec2(tx.x * i, 0);
		if(x.x < 0. || x.y < 0. || x.x > 1. || x.y > 1.) break;
		
		vec4 s = texture2D( gm_BaseTexture, x );
		vec4 b = texture2D( base, x );
		
		if(b.a == 0.) break;
		
		gl_FragColor.xy = less( gl_FragColor.xy, s.xy );
		gl_FragColor.zw = more( gl_FragColor.zw, s.zw );
	}
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec2 x = v_vTexcoord + vec2(0, tx.y * i);
		if(x.x < 0. || x.y < 0. || x.x > 1. || x.y > 1.) break;
		
		vec4 s = texture2D( gm_BaseTexture, x );
		vec4 b = texture2D( base, x );
		
		if(b.a == 0.) break;
		
		gl_FragColor.xy = less( gl_FragColor.xy, s.xy );
		gl_FragColor.zw = more( gl_FragColor.zw, s.zw );
	}
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec2 x = v_vTexcoord - vec2(0, tx.y * i);
		if(x.x < 0. || x.y < 0. || x.x > 1. || x.y > 1.) break;
		
		vec4 s = texture2D( gm_BaseTexture, x );
		vec4 b = texture2D( base, x );
		
		if(b.a == 0.) break;
		
		gl_FragColor.xy = less( gl_FragColor.xy, s.xy );
		gl_FragColor.zw = more( gl_FragColor.zw, s.zw );
	}
}
