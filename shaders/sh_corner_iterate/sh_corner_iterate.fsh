varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define SPAN 8.

uniform vec2 dimension;

void main() {
	vec2  tx = 1. / dimension;
	vec4  cc = texture2D( gm_BaseTexture, v_vTexcoord );
	float hh = cc.r;
	
	if(hh == 0.) {
		gl_FragColor = vec4(vec3(0.), 1.);
		return;
	}
	
	vec2 px, mn = cc.yz;
	vec4 ss;
	
	for(float i = 1.; i < SPAN; i++) {
		px = v_vTexcoord + vec2(i * tx.x, 0.);
		ss = texture2D( gm_BaseTexture, px );
		
		if(ss.r == 0.) break;
		
		if(ss.r > hh) {
			hh = ss.r; 
			mn = ss.yz;
		} else if(ss.r == hh) {
			if(distance(v_vTexcoord, ss.yz) < distance(v_vTexcoord, mn))
				mn = ss.yz; 
		}
	}
	
	for(float i = 1.; i < SPAN; i++) {
		px = v_vTexcoord - vec2(i * tx.x, 0.);
		ss = texture2D( gm_BaseTexture, px );
		
		if(ss.r == 0.) break;
		
		if(ss.r > hh) {
			hh = ss.r; 
			mn = ss.yz;
		} else if(ss.r == hh) {
			if(distance(v_vTexcoord, ss.yz) < distance(v_vTexcoord, mn))
				mn = ss.yz; 
		}
	}
	
	for(float i = 1.; i < SPAN; i++) {
		px = v_vTexcoord + vec2(0., i * tx.y);
		ss = texture2D( gm_BaseTexture, px );
		
		if(ss.r == 0.) break;
		
		if(ss.r > hh) {
			hh = ss.r; 
			mn = ss.yz;
		} else if(ss.r == hh) {
			if(distance(v_vTexcoord, ss.yz) < distance(v_vTexcoord, mn))
				mn = ss.yz; 
		}
	}
	
	for(float i = 1.; i < SPAN; i++) {
		px = v_vTexcoord - vec2(0., i * tx.y);
		ss = texture2D( gm_BaseTexture, px );
		
		if(ss.r == 0.) break;
		
		if(ss.r > hh) {
			hh = ss.r; 
			mn = ss.yz;
		} else if(ss.r == hh) {
			if(distance(v_vTexcoord, ss.yz) < distance(v_vTexcoord, mn))
				mn = ss.yz; 
		}
	}
	
	gl_FragColor = vec4(hh, mn, 1.);
}
