#pragma use(sampler_simple)

#region -- sampler_simple -- [1729740692.1417658]
    uniform int  sampleMode;
    
    vec4 sampleTexture( sampler2D texture, vec2 pos) {
        if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
            return texture2D(texture, pos);
        
             if(sampleMode <= 1) return vec4(0.);
        else if(sampleMode == 2) return texture2D(texture, clamp(pos, 0., 1.));
        else if(sampleMode == 3) return texture2D(texture, fract(pos));
        else if(sampleMode == 4) return vec4(vec3(0.), 1.);
        
        return vec4(0.);
    }
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
