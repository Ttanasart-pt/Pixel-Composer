//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;

vec4 less ( vec4 a, vec4 b ) {
	if(b.xy == vec2(0.)) return a;
	if(a.xy == vec2(0.)) return b;
	
	if(a.y < b.y)		return a;
	else if(a.y > b.y)	return b;
	else				return a.x < b.x? a : b;
}

vec4 sample ( vec2 position ) {
	if(position.x < 0.) return vec4(1.);
	if(position.y < 0.) return vec4(1.);
	if(position.x > 1.) return vec4(1.);
	if(position.y > 1.) return vec4(1.);
	
	return texture2D( gm_BaseTexture, position );
}

void main() {
	vec2 tx = 1. / dimension;
    vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
	gl_FragColor = c;
	
	if(c.rgb == vec3(0.)) return;
	if(c.rgb == vec3(1.)) {
		gl_FragColor = vec4( v_vTexcoord, 0., 1. );
		return;
	}
	
	vec4 l = sample( v_vTexcoord - vec2(tx.x, 0.) );
	vec4 r = sample( v_vTexcoord + vec2(tx.x, 0.) );
	vec4 u = sample( v_vTexcoord - vec2(0., tx.y) );
	vec4 d = sample( v_vTexcoord + vec2(0., tx.y) );
	
	gl_FragColor = less( gl_FragColor, l );
	gl_FragColor = less( gl_FragColor, r );
	gl_FragColor = less( gl_FragColor, u );
	gl_FragColor = less( gl_FragColor, d );
}
