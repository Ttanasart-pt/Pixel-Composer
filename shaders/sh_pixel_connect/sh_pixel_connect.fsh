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

uniform vec2  dimension;

uniform int   selfCon;
uniform float maxDistance;
uniform float angRes;

uniform int       useSurface;
uniform sampler2D connectSurf;

uniform int   blendType;
uniform int   blendMode;
uniform vec4  blendColor;

#define PI 3.14159265358979323846

bool oob(vec2 p) { return p.x < 0. || p.x >= 1. || p.y < 0. || p.y >= 1.; }

void main() {
	vec2 tx = 1. / dimension;
	vec4 cc = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = cc;
	
	if(selfCon == 0 && useSurface == 0) return;
	if(useSurface == 1) {
		vec4 cc = v_vColour * texture2D(connectSurf, v_vTexcoord);
		if(cc.a > 0.) {
			gl_FragColor = cc;
			return;
		}
	}
	
	float maxDist = maxDistance * dimension.x;
	
	bool  hasMin  = false;
	float minDist = 999999.;
	float minAng  = 999999.;
	vec2  minSolPos0;
	vec2  minSolPos1;
	
	vec4  minSolCol0;
	vec4  minSolCol1;
	
	float pxDist = length(tx);
	float base = 1.;
	float top  = 0.;
			
	for(float a = 0.; a < angRes; a++) {
		float angle = top / base * PI * 2.;
		top += 2.;
		if(top >= base) {
			top   = 1.;
			base *= 2.;
		}
		
		vec2  dd    = vec2(cos(angle), sin(angle)) * tx;
		
		vec2  solPos0;
		vec2  solPos1;
		
		vec2  conPos0;
		vec2  conPos1;
		
		vec4 solCol0;
		vec4 solCol1;
		
		float solDis0;
		float solDis1;
		
		bool solFound0 = false;
		bool empFound0 = false;
		bool empFound1 = false;
		
		int  sol0Has = 0;
		int  sol1Has = 0;
		
		for(float d = 1.; d < maxDist; d++) {
			vec2 sx0  = v_vTexcoord + dd * d;
			vec4 col0 = sampleTexture(gm_BaseTexture, sx0);
			
			if(col0.a > 0.) {
				solFound0 = true;
				
				sol0Has++;
				solDis0 = d;
				solPos0 = sx0;
				solCol0 = col0;
				
				if(selfCon == 1) break;
				
			} else {
				if(solFound0) break;
				
			}
			
		}
		
		if(sol0Has == 0) continue;
		
		for(float d = 1.; d < maxDist * 2.; d++) {
			vec2 sx0  = solPos0 - dd * d;
			vec4 col0 = sampleTexture(gm_BaseTexture, sx0);
			
			if(col0.a > 0. && !empFound0) conPos0   = sx0;
			if(col0.a == 0.)              empFound0 = true;
			
			if(useSurface == 1) col0 = sampleTexture(connectSurf, sx0);
			
			if(col0.a > 0.) {
				sol1Has++;
				solDis1 = d;
				solPos1 = sx0;
				solCol1 = col0;
				
				if(solDis1 >= solDis0 && empFound1) break;
				
			} else {
				empFound1 = true;
			}
		}
		
		if(selfCon == 1) conPos0 = solPos0;
		
		if(solDis0 > solDis1) continue;
		if(sol1Has == 0)      continue;
		
		float solDist = distance(
			floor(conPos0 * dimension), 
			floor(solPos1 * dimension)
		);
		
		if(solDist < minDist) {
			hasMin     = true;
			minDist    = solDist;
			minAng     = a;
			
			minSolPos0 = solPos0;
			minSolPos1 = solPos1;
			
			minSolCol0 = solCol0;
			minSolCol1 = solCol1;
		}
		
	}
	
	if(!hasMin) return;
	
	float d0 = distance(v_vTexcoord, minSolPos0);
	float d1 = distance(v_vTexcoord, minSolPos1);
	
	if(blendType == 0) {
		if(d0 < d1) gl_FragColor = minSolCol0;
		else        gl_FragColor = minSolCol1;
			
	} else {
		float td = d0 + d1;
		gl_FragColor = mix(minSolCol0, minSolCol1, d0 / td);
	}
	
	if(blendMode == 0) gl_FragColor  = blendColor;
	if(blendMode == 1) gl_FragColor *= blendColor;
	
}