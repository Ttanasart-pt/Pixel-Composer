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

uniform vec2      dimension;
uniform sampler2D original;

uniform vec2      radius;
uniform int       radiusUseSurf;
uniform sampler2D radiusSurf;

uniform vec2      threshold;
uniform int       thresholdUseSurf;
uniform sampler2D thresholdSurf;

void main() {
	float rad = radius.x;
	if(radiusUseSurf == 1) {
		vec4 _vMap = texture2D( radiusSurf, v_vTexcoord );
		rad = mix(radius.x, radius.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float thr = threshold.x;
	if(thresholdUseSurf == 1) {
		vec4 _vMap = texture2D( thresholdSurf, v_vTexcoord );
		thr = mix(threshold.x, threshold.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	gl_FragColor = vec4(0., 0., 0., 1.);
	
	vec4 cc = texture2D(gm_BaseTexture, v_vTexcoord);
	if(cc.a == 0.) return;
	
	vec2 tx = 1. / dimension;
	float kfill = 0.;
	float ksize = 0.;
	
	for(float i = -16.; i <= 16.; i++)
	for(float j = -16.; j <= 16.; j++) {
		if(abs(i) > rad || abs(j) > rad) continue;
		
		vec4 samp = sampleTexture(gm_BaseTexture, v_vTexcoord + vec2(i, j) * tx);
		ksize++;
		
		if(samp.rg != cc.rg) continue;
		kfill += samp.a;
	}
	
	bool isCorner = (kfill / ksize) < thr;
	
	if(!isCorner) gl_FragColor = texture2D(original, v_vTexcoord);
}