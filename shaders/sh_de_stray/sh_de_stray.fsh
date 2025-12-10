varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   strict;
uniform int   fill;

uniform vec2      tolerance;
uniform int       toleranceUseSurf;
uniform sampler2D toleranceSurf;

float tolr;

vec4  a4;
float d(in vec4 c1, in vec4 c2)    { return length(c1 - c2) / sqrt(4.); }
bool  s(in vec4 c1, in vec4 c2)    { return d(c1, c2) <= tolr; }

#region select closet color
	vec4  sel2(in vec4 c0, in vec4 c1) {
		float d0 = d(a4, c0);
		float d1 = d(a4, c1);
	
		float mn = min(d0, d1);
	
		if(mn == d0) return c0;
		             return c1;
	}

	vec4  sel3(in vec4 c0, in vec4 c1, in vec4 c2) {
		float d0 = d(a4, c0);
		float d1 = d(a4, c1);
		float d2 = d(a4, c2);
	
		float mn = min(min(d0, d1), d2);
	
		if(mn == d0) return c0;
		if(mn == d1) return c1;
		             return c2;
	}

	vec4  sel4(in vec4 c0, in vec4 c1, in vec4 c2, in vec4 c3) {
		float d0 = d(a4, c0);
		float d1 = d(a4, c1);
		float d2 = d(a4, c2);
		float d3 = d(a4, c3);
	
		float mn = min(min(d0, d1), min(d2, d3));
		
		if(mn == d0) return c0;
		if(mn == d1) return c1;
		if(mn == d2) return c2;
		             return c3;
	}
#endregion

void main() {
	tolr = tolerance.x;
	if(toleranceUseSurf == 1) {
		vec4 _vMap = texture2D( toleranceSurf, v_vTexcoord );
		tolr = mix(tolerance.x, tolerance.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec2 tx = 1. / dimension;
    
	// 0 1 2
	// 3 4 5
	// 6 7 8
	
	vec4 a0 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x, -tx.y)); 
	vec4 a1 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(   0., -tx.y));	
	vec4 a2 = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x, -tx.y));	
    																		
	vec4 a3 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x, 0.));	
	     a4 = texture2D( gm_BaseTexture, v_vTexcoord );						
	vec4 a5 = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x, 0.));	
																			
	vec4 a6 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x,  tx.y));	
	vec4 a7 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(   0.,  tx.y));	
	vec4 a8 = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x,  tx.y));	
	
	gl_FragColor = a4;
	if(a4.a == 0.) {
		if(fill == 0) return;
		
		gl_FragColor = sel4(a1, a3, a5, a7);
		return;
	}
	
	if(strict == 0) {
		if(!s(a4, a1) && s(a1, a3) && s(a1, a5)) gl_FragColor = sel3(a1, a3, a5);
		if(!s(a4, a3) && s(a3, a1) && s(a3, a7)) gl_FragColor = sel3(a3, a1, a7);
		if(!s(a4, a5) && s(a5, a1) && s(a5, a7)) gl_FragColor = sel3(a5, a1, a7);
		if(!s(a4, a7) && s(a7, a3) && s(a7, a5)) gl_FragColor = sel3(a7, a3, a5);
		
	} else if(strict == 1) {
		if(!s(a4, a1) && s(a1, a3) && s(a1, a5) && s(a1, a7)) 
			gl_FragColor = sel4(a1, a3, a5, a7);
			
	} else if(strict == 2) {
		if(!s(a4, a1) && s(a1, a3) && s(a1, a5) && s(a1, a7)
		 && s(a1, a0) && s(a1, a2) && s(a1, a6) && s(a1, a8)) 
			gl_FragColor = sel4(a1, a3, a5, a7);
	}
}
