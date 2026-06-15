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

#define TAU 6.28318530718

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;

uniform vec2      radius;
uniform int       radiusUseSurf;
uniform sampler2D radiusSurf;

uniform int   shape;
uniform int   fade;

uniform float threshold;
uniform float smoothness;

void main() {
	#region param
		float rad    = radius.x;
		float radMax = max(radius.x, radius.y);
		if(radiusUseSurf == 1) {
			vec4 _vMap = texture2D( radiusSurf, v_vTexcoord );
			rad = mix(radius.x, radius.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	#endregion
	
	vec2  tx = 1. / dimension;
	vec4  cc = vec4(0.);
	float dv = 0.;
	float da = 0.;
	
	if(shape == 0) {
		float aStep = TAU / 64.;
		for(float i = 0.; i < radMax; i++) {
			if(i > rad) break;
			
			for(float j = 0.; j < TAU; j += aStep) {
				vec2  sx = v_vTexcoord + vec2(cos(j), sin(j)) * tx * i;
				vec4  c  = sampleTexture( gm_BaseTexture, sx );
				float s  = fade == 1? 1. - i / rad : 1.;
				
				cc += c   * s;
				da += c.a * s;
				dv += s;
			}
		}
		
	} else if(shape == 1) {
		for(float i = -radMax; i <= radMax; i++) 
		for(float j = -radMax; j <= radMax; j++) {
			if(i < -rad || j < -rad || i > rad || j > rad) continue;
			
			vec2  sx = v_vTexcoord + vec2(i, j) * tx;
			vec4  c  = sampleTexture( gm_BaseTexture, sx );
			float s  = fade == 1? 1. - max(abs(i), abs(j)) / rad : 1.;
			
			cc += c   * s;
			da += c.a * s;
			dv += s;
		}
		
	} else if(shape == 2) {
		for(float i = -radMax; i <= radMax; i++) 
		for(float j = -radMax; j <= radMax; j++) {
			if(abs(i) + abs(j) > rad) continue;
			
			vec2  sx = v_vTexcoord + vec2(i, j) * tx;
			vec4  c  = sampleTexture( gm_BaseTexture, sx );
			float s  = fade == 1? 1. - (abs(i) + abs(j)) / rad : 1.;
			
			cc += c   * s;
			da += c.a * s;
			dv += s;
		}
		
	}
	
	cc /= dv;
	// cc /= da;
	
	vec4 res = cc;
	
	if(smoothness == 0.) 
    	 res = step(threshold, cc);
    else res = smoothstep(threshold - smoothness/2., threshold + smoothness/2., cc);
	
	gl_FragColor = res;
}
