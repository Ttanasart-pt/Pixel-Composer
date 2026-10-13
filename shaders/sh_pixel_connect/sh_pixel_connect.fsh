#pragma use(sampler_simple)
#region -- sampler_simple -- [1788846732.6884737]
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
uniform float maxDistance;
uniform float angRes;

uniform int   blendType;
uniform int   blendMode;
uniform vec4  blendColor;

#define PI 3.14159265358979323846

bool oob(vec2 p) { return p.x < 0. || p.x >= 1. || p.y < 0. || p.y >= 1.; }

void main() {
	vec2 tx = 1. / dimension;
	vec4 cc = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = cc;
	if(cc.a > 0.) return;
	
	float maxDist = maxDistance * dimension.x;
	
	bool  hasMin  = false;
	float minDist = 999999.;
	vec2  minSolPos0;
	vec2  minSolPos1;
	
	vec4  minSolCol0;
	vec4  minSolCol1;
	
	float pxDist = length(tx);
	
	for(float a = 0.; a < angRes; a++) {
		float angle = PI * a / angRes;
		vec2  dd    = vec2(cos(angle), sin(angle)) * tx;
		
		vec2 solPos0;
		vec2 solPos1;
		
		vec4 solCol0;
		vec4 solCol1;

		int  solHas = 0;
		
		for(float d = 1.; d < maxDist; d++) {
			vec2 sx0  = v_vTexcoord + dd * d;
			vec4 col0 = sampleTexture(gm_BaseTexture, sx0);
			
			if(col0.a > 0.) {
				solHas++;
				solPos0 = sx0;
				solCol0 = col0;
				break;
			} 
		}
		
		if(solHas == 0) continue;
		
		for(float d = 1.; d < maxDist * 2.; d++) {
			if(d >= dimension.x - 1.) break;
			
			vec2 sx0  = solPos0 - dd * d;
			vec4 col0 = sampleTexture(gm_BaseTexture, sx0);
			
			if(col0.a > 0.) {
				solHas++;
				solPos1 = sx0;
				solCol1 = col0;
				break;
			} 
		}
		
		if(solHas == 1) continue;
		
		float solDist = distance(solPos0, solPos1);
		if(solDist < minDist) {
			hasMin     = true;
			minDist    = solDist;
			
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