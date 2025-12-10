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
uniform int   blend;

uniform vec2      radius;
uniform int       radiusUseSurf;
uniform sampler2D radiusSurf;

uniform vec2      intensity;
uniform int       intensityUseSurf;
uniform sampler2D intensitySurf;

void main() {
	float rad    = radius.x;
	float radMax = max(radius.x, radius.y);
	if(radiusUseSurf == 1) {
		vec4 _vMap = texture2D( radiusSurf, v_vTexcoord );
		rad = mix(radius.x, radius.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float ins = intensity.x;
	if(intensityUseSurf == 1) {
		vec4 _vMap = texture2D( intensitySurf, v_vTexcoord );
		ins = mix(intensity.x, intensity.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
    vec2  tx = 1. / dimension;
    vec4  ss = vec4(0.);
    float ww = 0.;
    
    rad    = floor(rad);
    radMax = floor(radMax);
    
    for(float i = -radMax; i <= radMax; i++) {
    	if(i < -rad) continue;
    	if(i >  rad) break;
    	
	    for(float j = -radMax; j <= radMax; j++) {
	    	if(j < -rad) continue;
			if(j >  rad) break;
    	
	        if(i == 0. && j == 0.) continue;
	        
	        vec2 sx = v_vTexcoord + vec2(i, j) * tx;
	        float w = (rad - (abs(i) + abs(j)) + 1.) / rad / 4.;
	        if(w <= 0.) continue;
	        
	        ss -= sampleTexture( gm_BaseTexture, sx ) * w;
	        ww += w;
	    }
    }
    
    vec4 sc = sampleTexture( gm_BaseTexture, v_vTexcoord );
         ss += sc * ww;
    
    vec4 res = ss * ins;
    if(blend == 1) res += sc;
    res.a = sc.a;
    
    gl_FragColor = res;
}
