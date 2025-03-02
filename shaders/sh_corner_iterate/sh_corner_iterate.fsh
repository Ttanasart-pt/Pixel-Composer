varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define SPAN 8.

uniform vec2 dimension;

vec2 min2(vec2 a, vec2 b) { return a.y < b.y? a : (a.x < b.x? a : b); }

void main() {
	vec2  tx = 1. / dimension;
	vec4  cc = texture2D( gm_BaseTexture, v_vTexcoord );
	
	gl_FragColor = vec4(0.);
	if(cc.a == 0.) return;
	
	vec4 ss;
	vec2 cx = cc.xy;
	
	for(float i = 1.; i <= SPAN; i++) {
		ss = texture2D( gm_BaseTexture, v_vTexcoord + vec2(i * tx.x, 0.) );
		if(ss.a == 0.) break;
		
		cx = min(cx, ss.xy);
	}
	
	for(float i = 1.; i <= SPAN; i++) {
		ss = texture2D( gm_BaseTexture, v_vTexcoord - vec2(i * tx.x, 0.) );
		if(ss.a == 0.) break;
		
		cx = min(cx, ss.xy);
	}
	
	for(float i = 1.; i <= SPAN; i++) {
		ss = texture2D( gm_BaseTexture, v_vTexcoord + vec2(0., i * tx.y) );
		if(ss.a == 0.) break;
		
		cx = min(cx, ss.xy);
	}
	
	for(float i = 1.; i <= SPAN; i++) {
		ss = texture2D( gm_BaseTexture, v_vTexcoord - vec2(0., i * tx.y) );
		if(ss.a == 0.) break;
		
		cx = min(cx, ss.xy);
	}
	
	gl_FragColor = vec4(cx, 0., 1.);
}
