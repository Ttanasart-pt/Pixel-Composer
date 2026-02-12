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

uniform vec2      intensity;
uniform int       intensityUseSurf;
uniform sampler2D intensitySurf;

uniform vec2      radius;
uniform int       radiusUseSurf;
uniform sampler2D radiusSurf;

void main() {
	float rad    = radius.x;
	float radMax = floor(max(radius.x, radius.y));
	if(radiusUseSurf == 1) {
		vec4 _vMap = texture2D( radiusSurf, v_vTexcoord );
		rad = mix(radius.x, radius.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float itn    = intensity.x;
	if(intensityUseSurf == 1) {
		vec4 _vMap = texture2D( intensitySurf, v_vTexcoord );
		itn = mix(intensity.x, intensity.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
    vec2 tx = 1. / dimension;
    vec2 uv = getUV(v_vTexcoord);

	vec4 meanColor = vec4(0.);
    vec4 v = sampleTexture( gm_BaseTexture, uv );
    int count = 0;
    int irad  = int(radMax);

    for(int y = 0; y <= irad; y++) {
    	if(y > int(rad)) break;
    	
        for(int x = -irad; x <= irad; x++) {
        	if(x < -int(rad)) continue;
        	if(x >  int(rad)) break;
        	
            vec4 v1 = sampleTexture( gm_BaseTexture, uv + vec2( x,  y) * tx );
            vec4 v2 = sampleTexture( gm_BaseTexture, uv + vec2(-x, -y) * tx );

            vec4 d1 = abs(v - v1);
            vec4 d2 = abs(v - v2);

            vec4 rv = vec4(
            	((d1[0] < d2[0]) ? v1[0] : v2[0]),
                ((d1[1] < d2[1]) ? v1[1] : v2[1]),
                ((d1[2] < d2[2]) ? v1[2] : v2[2]),
                1
            );

            meanColor += rv;
            count++;
        }
    }

    meanColor /= float(count);
    gl_FragColor = mix(v, meanColor, itn);
}