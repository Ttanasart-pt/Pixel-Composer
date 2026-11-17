#pragma use(sampler_simple)
#region -- sampler_simple -- [1794912035.362913]
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

    vec2 getUVA(in vec2 uv, out float alpha) {
        if(useUvMap == 0) {
            alpha = 1.0;
            return uv;
        }

        vec4 samUV = texture2D( uvMap, uv );
        vec2 vuv = vec2(samUV.x, 1. - samUV.y);
        alpha    = samUV.a;

        vec2 vtx = mix(uv, vuv, uvMapMix);
        return vtx;
    }

    vec2 getSamplePos(vec2 pos, float mapBlend) {
        if(useUvMap == 1) {
            vec2 map = texture2D(uvMap, pos).xy;
            map.y    = 1.0 - map.y;
            pos      = mix(pos, map, mapBlend * uvMapMix);
        }

        if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
            return pos;
        
		     if(sampleMode == 3) return clamp(pos, 0., 1.);
		else if(sampleMode == 4) return fract(pos);
        // 5
		else if(sampleMode == 6) { vec2 sp = vec2(fract(pos.x), pos.y); return sp; } 
		else if(sampleMode == 7) { vec2 sp = vec2(fract(pos.x), pos.y); return sp; } 
		else if(sampleMode == 8) return vec2(fract(pos.x), clamp(pos.y, 0., 1.));
		// 9
		else if(sampleMode == 10) { vec2 sp = vec2(pos.x, fract(pos.y)); return sp; } 
		else if(sampleMode == 11) { vec2 sp = vec2(pos.x, fract(pos.y)); return sp; } 
		else if(sampleMode == 12) return vec2(clamp(pos.x, 0., 1.), fract(pos.y));
		
        return pos;
    }
    vec2 getSamplePos(vec2 pos) { return getSamplePos(pos, 0.); }
    
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

#define ITERATION 2.

uniform sampler2D original;
uniform vec2 dimension;

void main() {
	vec2 tx = 1. / dimension;
	vec4 c  = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 o  = texture2D( original,       v_vTexcoord );
	
	gl_FragColor = c;
	if(c.a > 0.) return;
	
	float minD = ITERATION;
	
	for( float i = 1.; i < ITERATION; i++ ) {
		if(i >= minD) break;
		
		vec2 x = v_vTexcoord + vec2(tx.x * i, 0.);
		     x = getSamplePos(x);
		if(x.x < 0. || x.y < 0. || x.x > 1. || x.y > 1.) break;
		
		vec4 s = sampleTexture( gm_BaseTexture, x );
		if(s.a == 0.) continue;
		
		gl_FragColor = s * v_vColour;
		minD = i;
	}
    
	for( float i = 1.; i < ITERATION; i++ ) {
		if(i >= minD) break;
		
		vec2 x = v_vTexcoord - vec2(tx.x * i, 0.);
		     x = getSamplePos(x);
		if(x.x < 0. || x.y < 0. || x.x > 1. || x.y > 1.) break;
		
		vec4 s = sampleTexture( gm_BaseTexture, x );
		if(s.a == 0.) continue;
		
		gl_FragColor = s * v_vColour;
		minD = i;
	}
    
	for( float i = 1.; i < ITERATION; i++ ) {
		if(i >= minD) break;
		
		vec2 x = v_vTexcoord + vec2(0., tx.y * i);
		     x = getSamplePos(x);
		if(x.x < 0. || x.y < 0. || x.x > 1. || x.y > 1.) break;
		
		vec4 s = sampleTexture( gm_BaseTexture, x );
		if(s.a == 0.) continue;
		
		gl_FragColor = s * v_vColour;
		minD = i;
	}
    
	for( float i = 1.; i < ITERATION; i++ ) {
		if(i >= minD) break;
		
		vec2 x = v_vTexcoord - vec2(0., tx.y * i);
		     x = getSamplePos(x);
		if(x.x < 0. || x.y < 0. || x.x > 1. || x.y > 1.) break;
		
		vec4 s = sampleTexture( gm_BaseTexture, x );
		if(s.a == 0.) continue;
		
		gl_FragColor = s * v_vColour;
		minD = i;
	}
}
