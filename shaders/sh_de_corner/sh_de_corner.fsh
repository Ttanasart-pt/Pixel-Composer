#pragma use(sampler_simple)

#region -- sampler_simple -- [1765194569.6586206]
    uniform int  sampleMode;
    
    uniform sampler2D uvMap;
    uniform int   useUvMap;
    uniform float uvMapMix;

    vec2 getUV(vec2 tx) {
        if(useUvMap == 1) {
            vec2 map = texture2D(uvMap, tx).xy;
            map.y    = 1.0 - map.y;
            tx       = mix(tx, map, uvMapMix);
        }
        return tx;
    }

    vec4 sampleTexture( sampler2D texture, vec2 pos, float mapBlend) {
        if(useUvMap == 1) {
            vec2 map = texture2D(uvMap, pos).xy;
            map.y    = 1.0 - map.y;
            pos      = mix(pos, map, mapBlend * uvMapMix);
        }

        if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
            return texture2D(texture, pos);
        
			 if(sampleMode <= 1) return vec4(0.);
		else if(sampleMode == 2) return vec4(0.,0.,0., 1.);
		else if(sampleMode == 3) return texture2D(texture, clamp(pos, 0., 1.));
		else if(sampleMode == 4) return texture2D(texture, fract(pos));
        // 5
		else if(sampleMode == 6) { vec2 sp = vec2(fract(pos.x), pos.y); return (sp.y < 0. || sp.y > 1.) ? vec4(0.) : texture2D(texture, sp); } 
		else if(sampleMode == 7) { vec2 sp = vec2(fract(pos.x), pos.y); return (sp.y < 0. || sp.y > 1.) ? vec4(0.,0.,0.,1.) : texture2D(texture, sp); } 
		else if(sampleMode == 8) return texture2D(texture, vec2(fract(pos.x), clamp(pos.y, 0., 1.)));
		// 9
		else if(sampleMode == 10) { vec2 sp = vec2(pos.x, fract(pos.y)); return (sp.x < 0. || sp.x > 1.) ? vec4(0.) : texture2D(texture, sp); } 
		else if(sampleMode == 11) { vec2 sp = vec2(pos.x, fract(pos.y)); return (sp.x < 0. || sp.x > 1.) ? vec4(0.,0.,0.,1.) : texture2D(texture, sp); } 
		else if(sampleMode == 12) return texture2D(texture, vec2(clamp(pos.x, 0., 1.), fract(pos.y)));
		
        return vec4(0.);
    }
    vec4 sampleTexture( sampler2D texture, vec2 pos) { return sampleTexture(texture, pos, 0.); }
#endregion -- sampler_simple --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   strict;
uniform int   inner;
uniform int   side;

uniform vec2      tolerance;
uniform int       toleranceUseSurf;
uniform sampler2D toleranceSurf;

float tolr;

float d(in vec4 c1, in vec4 c2) { return length(c1.rgb * c1.a - c2.rgb * c2.a) / sqrt(3.); }

vec4  a4;
bool  s(in vec4 c2) 			{ return d(a4, c2) <= tolr; }
bool  s(in bool b,  in vec4 c2) { return b || d(a4, c2) <= tolr; }

bool  s(in vec4 c1, in vec4 c2) 			{ return d(c1, c2) <= tolr; }
bool  s(in bool b,  in vec4 c1, in vec4 c2) { return b || d(c1, c2) <= tolr; }

bool ns(in vec4 c2) 			{ return d(a4, c2) > tolr; }
bool ns(in bool b,  in vec4 c2) { return b || d(a4, c2) > tolr; }

bool ns(in vec4 c1, in vec4 c2) 			{ return d(c1, c2) > tolr; }
bool ns(in bool b,  in vec4 c1, in vec4 c2) { return b || d(c1, c2) > tolr; }

float bright(in vec4 c) { return dot(c.rgb, vec3(0.2126, 0.7152, 0.0722)) * c.a; }

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
	
	// 0 1 2 
	// 3 4 5
	// 6 7 8
	
	a4 = texture2D( gm_BaseTexture, v_vTexcoord );
	vec2 tx = 1. / dimension;
	gl_FragColor = a4; 
	
	if(a4.a == 0.) return;
	
	vec4 a0 = sampleTexture( gm_BaseTexture, v_vTexcoord + vec2(-tx.x,  -tx.y) );
	vec4 a1 = sampleTexture( gm_BaseTexture, v_vTexcoord + vec2(    0., -tx.y) );
	vec4 a2 = sampleTexture( gm_BaseTexture, v_vTexcoord + vec2( tx.x,  -tx.y) );
													    
	vec4 a3 = sampleTexture( gm_BaseTexture, v_vTexcoord + vec2(-tx.x,     .0) );
	vec4 a5 = sampleTexture( gm_BaseTexture, v_vTexcoord + vec2( tx.x,     .0) );
													    
	vec4 a6 = sampleTexture( gm_BaseTexture, v_vTexcoord + vec2(-tx.x,   tx.y) );
	vec4 a7 = sampleTexture( gm_BaseTexture, v_vTexcoord + vec2(    0.,  tx.y) );
	vec4 a8 = sampleTexture( gm_BaseTexture, v_vTexcoord + vec2( tx.x,   tx.y) );
		
	bool n = inner == 0;
	bool d =  side == 0;
		
	if(strict == 0) {
		
		if(s(n, a0) && s(a1) && s(a3) && ns(d, a2) && ns(d, a5) && ns(d, a6) && ns(d, a7) && ns(a8)) {	// A A 2 
																										// A A 5
																										// 6 7 8
			gl_FragColor = n? sel3(a5, a7, a8) : sel3(sel2(a2, a6), sel2(a5, a7), a8);
			return; 
		}
		
		if(s(a1) && s(n, a2) && s(a5) && ns(d, a0) && ns(d, a3) && ns(a6) && ns(d, a7) && ns(d, a8)) {	// 0 A A 
																										// 3 A A
																										// 6 7 8
			gl_FragColor = n? sel3(a3, a6, a7) : sel3(sel2(a0, a8), sel2(a3, a7), a6);
			return;
		}
		
		if(s(a3) && s(n, a6) && s(a7) && ns(d, a0) && ns(d, a1) && ns(a2) && ns(d, a5) && ns(d, a8)) {	// 0 1 2 
																										// A A 5
																										// A A 8
			gl_FragColor = n? sel3(a1, a2, a5) : sel3(sel2(a0, a8), sel2(a1, a5), a2);
			return;
		}
		
		if(s(a5) && s(a7) && s(n, a8) && ns(a0) && ns(d, a1) && ns(d, a2) && ns(d, a3) && ns(d, a6)) {	// 0 1 2 
																										// 3 A A
																										// 6 A A
			gl_FragColor = n? sel3(a0, a1, a3) : sel3(sel2(a2, a6), sel2(a1, a3), a0);
			return;
		}
		
	} else if(strict == 1) {
		if(s(a5, a7) && s(a1) && s(a3) && s(n, a0) && ns(d, a2) && ns(d, a5) && ns(d, a6) && ns(d, a7)) {	// B B C 
																											// B B A
																											// C A 8
			gl_FragColor = n? sel3(a5, a7, a8) : sel3(sel2(a2, a6), sel2(a5, a7), a8);
			return;
		}
	
		if(s(a3, a7) && s(a1) && s(n, a2) && s(a5) && ns(d, a0) && ns(d, a3) && ns(d, a7) && ns(d, a8)) {	// C B B 
																											// A B B
																											// 6 A C
			gl_FragColor = n? sel3(a3, a6, a7) : sel3(sel2(a0, a8), sel2(a3, a7), a6);
			return;
		}
	
		if(s(a5, a1) && s(a3) && s(n, a6) && s(a7) && ns(d, a0) && ns(d, a1) && ns(d, a5) && ns(d, a8)) {	// C A 2 
																											// B B A
																											// B B C
			gl_FragColor = n? sel3(a1, a2, a5) : sel3(sel2(a0, a8), sel2(a1, a5), a2);
			return;
		}
	
		if(s(a3, a1) && s(a5) && s(n, a8) && s(a7) && ns(d, a2) && ns(d, a1) && ns(d, a3) && ns(d, a6)) {	// 0 A C
																											// A B B
																											// C B B
			gl_FragColor = n? sel3(a0, a1, a3) : sel3(sel2(a2, a6), sel2(a1, a3), a0);
			return;
		}
	}
}
