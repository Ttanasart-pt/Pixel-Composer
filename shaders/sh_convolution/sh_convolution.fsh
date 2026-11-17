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

uniform int   size;
uniform float kernel[256];
uniform float intensity;

uniform int   normalized;
uniform int   absolute;
uniform float rotation;

void main() {
	vec2  tx  = 1. / dimension;
	float sum = 1.;
	
	if(normalized == 1) {
		sum = 0.;
		int amo = size * size;
		for(int i = 0; i < amo; i++) sum += kernel[i];
		
		if(sum == 0.) sum = 1.;
	}
	
	float ang = radians(rotation);
	mat2  rot =  mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
	
	float st = -(float(size) - 1.) / 2.;
	vec4  c  = vec4(0.);
	
	for(int i = 0; i < size; i++)
	for(int j = 0; j < size; j++) {
		int  index = i * size + j;
		
		vec2 of  = (vec2(float(j), float(i)) + st) * tx;
		     of *= rot;
		
		vec2 px = v_vTexcoord + of;
		
		float w = kernel[index];
		if(w == 0.) continue;
		
		c += w * sampleTexture( gm_BaseTexture, px) / sum;
	}
	
	if(absolute == 1) c = abs(c);
	
    gl_FragColor = c * v_vColour * intensity;
}
