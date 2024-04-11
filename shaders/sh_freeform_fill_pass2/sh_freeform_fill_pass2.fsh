varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float itr;

float isInside(vec2 axis) {
	vec2 tx = 1. / dimension;
	
	float overlap = 0.;
	bool  filling = false;
	
	for(float i = 1.; i < itr; i++) {
		vec2 sx = v_vTexcoord + axis * tx * i;
		if(sx.x > 1. || sx.y > 1. || sx.x < 0. || sx.y < 0.) break;
		
		vec4 cc = texture2D( gm_BaseTexture, sx );
		
		if(cc == v_vColour) {
			if(!filling) overlap++;
			filling = true;
			
		} else 
			filling = false;
	}
	
	return mod(overlap, 2.);
}

void main() {
	vec2 tx = 1. / dimension;
	vec4 c  = texture2D( gm_BaseTexture, v_vTexcoord );
	
	gl_FragColor = vec4(0.);
	gl_FragColor = c; return;
	
	if(c == vec4(1.)) {
		gl_FragColor = v_vColour;
		return;
	}
	
	if(c == vec4(1., 0., 0., 1.)) {
		float _chk = 0.;
		
		c = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x, 0.) );
		if(c == vec4(1.) || c == vec4(0., 1., 0., 1.) || c == vec4(0., 0., 1., 1.)) _chk++;
		
		c = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x, 0.) );
		if(c == vec4(1.) || c == vec4(0., 1., 0., 1.) || c == vec4(0., 0., 1., 1.)) _chk++;
		
		c = texture2D( gm_BaseTexture, v_vTexcoord + vec2(0., -tx.y) );
		if(c == vec4(1.) || c == vec4(0., 1., 0., 1.) || c == vec4(0., 0., 1., 1.)) _chk++;
		
		c = texture2D( gm_BaseTexture, v_vTexcoord + vec2(0.,  tx.y) );
		if(c == vec4(1.) || c == vec4(0., 1., 0., 1.) || c == vec4(0., 0., 1., 1.)) _chk++;
		
		if(_chk < 2.) return;
		
	} else if(c == vec4(0., 1., 0., 1.)) {
		float _chk = 0.;
		
		c = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x, 0.) );
		if(c == vec4(1.) || c == vec4(0., 1., 0., 1.) || c == vec4(0., 0., 1., 1.)) _chk++;
		
		c = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x, 0.) );
		if(c == vec4(1.) || c == vec4(0., 1., 0., 1.) || c == vec4(0., 0., 1., 1.)) _chk++;
		
		c = texture2D( gm_BaseTexture, v_vTexcoord + vec2(0., -tx.y) );
		if(c == vec4(1.) || c == vec4(0., 1., 0., 1.) || c == vec4(0., 0., 1., 1.)) _chk++;
		
		c = texture2D( gm_BaseTexture, v_vTexcoord + vec2(0.,  tx.y) );
		if(c == vec4(1.) || c == vec4(0., 1., 0., 1.) || c == vec4(0., 0., 1., 1.)) _chk++;
		
		if(_chk < 2.) return;
		
	} else if(c == vec4(0., 0., 1., 1.)) {
		float _chk = 0.;
		
		c = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x, 0.) );
		if(c == vec4(1.) || c == vec4(0., 0., 1., 1.)) _chk++;
		
		c = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x, 0.) );
		if(c == vec4(1.) || c == vec4(0., 0., 1., 1.)) _chk++;
		
		c = texture2D( gm_BaseTexture, v_vTexcoord + vec2(0., -tx.y) );
		if(c == vec4(1.) || c == vec4(0., 0., 1., 1.)) _chk++;
		
		c = texture2D( gm_BaseTexture, v_vTexcoord + vec2(0.,  tx.y) );
		if(c == vec4(1.) || c == vec4(0., 0., 1., 1.)) _chk++;
		
		if(_chk < 2.) return;
	} else 
		return;
	
	gl_FragColor = v_vColour;
	
}
