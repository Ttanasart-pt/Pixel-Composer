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

uniform vec2 dimension;

uniform float direction;
uniform float maxDistance;

uniform float height;

uniform vec4  shadowColor;
uniform float shadowIntensity;
uniform float shadowShade;
uniform float shadowHeightMod;

float grey(vec4 clr) { return (clr.r + clr.g + clr.b) / 3. * clr.a; }

void main() {
	vec2 tx = 1. / dimension;
	float maxD = abs(maxDistance) * tx.x;
	
	vec4  baseC = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
	float baseG = grey(baseC);
	gl_FragColor = baseC;
	
	float dir = direction;
	if(maxDistance < 0.) 
		dir += 180.;
    dir = radians(dir);
    
	vec2  ofs = tx * vec2(cos(dir), -sin(dir));
	
	bool  isShaded    = false;
	float shadeDist   = 0.;
	float shadeHeight = 0.;
	float maxDist     = ceil(abs(maxDistance));
	
	for(float i = 1.; i < maxDist; i++) {
		vec2  sx = v_vTexcoord - ofs * i;
		vec4  sampC = sampleTexture(gm_BaseTexture, sx);
		float sampG = grey(sampC);
		if(sampG <= baseG) continue;
		
		float shadowDist = (sampG - baseG) * height;
		if(shadowDist < i) continue;
		
		shadeDist    = i;
		shadeHeight  = sampG;
		isShaded     = true;
		break;
	}
	 
	if(!isShaded) return;
	
	float ints = shadowIntensity;
	
	ints = mix(ints, ints * clamp(1. - shadeDist / abs(maxDistance), 0., 1.), shadowShade);
	ints = mix(ints, ints * clamp(shadeHeight - baseG, 0., 1.), shadowHeightMod);
	
	vec4 shadC = mix(baseC, baseC * shadowColor, ints);
	shadC.a = baseC.a;
	
	gl_FragColor = shadC;
}