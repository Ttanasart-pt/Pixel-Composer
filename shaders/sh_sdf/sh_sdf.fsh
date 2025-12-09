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
uniform float stepSize;
uniform int side;

void main() {
	float c = sampleTexture( gm_BaseTexture, v_vTexcoord ).z;
	if((side == 0 && c == 0.) || (side == 1 && c == 1.)) {
		gl_FragColor = sampleTexture( gm_BaseTexture, v_vTexcoord );
		return;
	}
	
	vec2 txStep = stepSize / dimension;
	vec2 loc[9];
	
	loc[0] = v_vTexcoord + vec2(-txStep.x, -txStep.y);
	loc[1] = v_vTexcoord + vec2(       0., -txStep.y);
	loc[2] = v_vTexcoord + vec2(+txStep.x, -txStep.y);
	
	loc[3] = v_vTexcoord + vec2(-txStep.x, 0.);
	loc[4] = v_vTexcoord + vec2(       0., 0.);
	loc[5] = v_vTexcoord + vec2(+txStep.x, 0.);
	
	loc[6] = v_vTexcoord + vec2(-txStep.x, +txStep.y);
	loc[7] = v_vTexcoord + vec2(       0., +txStep.y);
	loc[8] = v_vTexcoord + vec2(+txStep.x, +txStep.y);
	
	vec2 closetPoint = vec2(0., 0.);
	float closetDistance = 9999.;
	
	for( int i = 0 ; i < 9; i++ ) {
		vec4 sam = sampleTexture( gm_BaseTexture, loc[i] );
		
		if(sam.z != c) {
			float dist = distance(v_vTexcoord, loc[i]);
			if(dist < closetDistance) {
				closetDistance = dist;
				closetPoint = loc[i];
			}
			continue;
		}
		
		if(sam.xy == vec2(0.)) continue;
		float dist = distance(v_vTexcoord, sam.xy);
		if(dist < closetDistance) {
			closetDistance = dist;
			closetPoint = sam.xy;
		}
	}
	
	gl_FragColor = vec4(closetPoint, c, 1.);
}
