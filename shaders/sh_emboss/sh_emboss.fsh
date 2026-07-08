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

uniform vec2 dimension;

uniform float direction;
uniform int   deboss;

uniform vec2      intensity;
uniform int       intensityUseSurf;
uniform sampler2D intensitySurf;

uniform int       usebaseBG;
uniform sampler2D baseBG;

uniform vec4  color;

float bright(vec4 c) { return (c.r + c.g + c.b) / 3. * c.a; }

void main() {
	#region param
		float its    = intensity.x;
		if(intensityUseSurf == 1) {
			vec4 _vMap = texture2D( intensitySurf, v_vTexcoord );
			its = mix(intensity.x, intensity.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		its += 1.;
	#endregion
	
	vec2  tx     = 1. / dimension;
	vec4  base   = texture2D(gm_BaseTexture, v_vTexcoord);
	float baseBr = bright(base);
	
	vec4  baseC  = base;
	if(usebaseBG == 1)
		baseC  = texture2D(baseBG, v_vTexcoord);
	
	float dirr = radians(direction);
	bool  colr = false;
	
	vec2  offset = vec2(cos(dirr), -sin(dirr));
	vec4  samp   = sampleTexture(gm_BaseTexture, v_vTexcoord + offset * tx);
	float sampBr = bright(samp);
	if((deboss == 0 && sampBr < baseBr) || (deboss == 1 && sampBr > baseBr)) {
		baseC.rgb *= its;
		colr = !colr;
	}
	
	samp   = sampleTexture(gm_BaseTexture, v_vTexcoord - offset * tx);
	sampBr = bright(samp);
	if((deboss == 0 && sampBr < baseBr) || (deboss == 1 && sampBr > baseBr)) {
		baseC.rgb /= its;
		colr = !colr;
	}
	
	if(colr) baseC.rgb *= color.rgb;
	
	gl_FragColor = baseC;
}