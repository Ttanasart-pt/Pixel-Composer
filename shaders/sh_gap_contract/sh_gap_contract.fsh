#pragma use(sampler_simple)

#region -- sampler_simple -- [1764837291.6127295]
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
        else if(sampleMode == 2) return texture2D(texture, clamp(pos, 0., 1.));
        else if(sampleMode == 3) return texture2D(texture, fract(pos));
        else if(sampleMode == 4) return vec4(vec3(0.), 1.);
        
        return vec4(0.);
    }
    vec4 sampleTexture( sampler2D texture, vec2 pos) { return sampleTexture(texture, pos, 0.); }
#endregion -- sampler_simple --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  process;
uniform int  inverted;

float light(vec4 cc) { return (cc.r + cc.g + cc.b) / 3. * cc.a; } 
float bw(vec4 cc) { return step(.5, light(cc)); }

void main() {
	vec2 tx = 1. / dimension;
	vec4 cc = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = cc;
	
	float p1 = bw(cc);
	
	float p9 = bw(sampleTexture(gm_BaseTexture, v_vTexcoord + vec2(-tx.x, -tx.y)));
	float p2 = bw(sampleTexture(gm_BaseTexture, v_vTexcoord + vec2(   0., -tx.y)));
	float p3 = bw(sampleTexture(gm_BaseTexture, v_vTexcoord + vec2( tx.x, -tx.y)));
	
	float p8 = bw(sampleTexture(gm_BaseTexture, v_vTexcoord + vec2(-tx.x, 0.)));
	float p4 = bw(sampleTexture(gm_BaseTexture, v_vTexcoord + vec2( tx.x, 0.)));
	
	float p7 = bw(sampleTexture(gm_BaseTexture, v_vTexcoord + vec2(-tx.x, tx.y)));
	float p6 = bw(sampleTexture(gm_BaseTexture, v_vTexcoord + vec2(   0., tx.y)));
	float p5 = bw(sampleTexture(gm_BaseTexture, v_vTexcoord + vec2( tx.x, tx.y)));
	
	float a = 0.;
	if(p2 == 0. && p3 == 1.) a += 1.;
	if(p3 == 0. && p4 == 1.) a += 1.;
	if(p4 == 0. && p5 == 1.) a += 1.;
	if(p5 == 0. && p6 == 1.) a += 1.;
	if(p6 == 0. && p7 == 1.) a += 1.;
	if(p7 == 0. && p8 == 1.) a += 1.;
	if(p8 == 0. && p9 == 1.) a += 1.;
	if(p9 == 0. && p2 == 1.) a += 1.;
	
	float b = p9 + p2 + p3 + p8 + p4 + p7 + p6 + p5;
	float pass = p1;
	
	if(inverted == 0) {
		if(process == 0) {
			if((p1 == 1.)                         && 
			   (2. <= b && b <= 6.)               && 
			   (a == 1.)                          && 
			   (p2 == 0. || p4 == 0. || p6 == 0.) && 
			   (p4 == 0. || p6 == 0. || p8 == 0.) ) 
				  pass = 0.;
				  
		} else if(process == 1) {
			if((p1 == 1.)                         && 
			   (2. <= b && b <= 6.)               && 
			   (a == 1.)                          && 
			   (p2 == 0. || p4 == 0. || p8 == 0.) && 
			   (p2 == 0. || p6 == 0. || p8 == 0.) ) 
				  pass = 0.;
		}
		
	} else {
		if(process == 0) {
			if((p1 == 0.)                         && 
			   (2. <= b && b <= 6.)               && 
			   (a == 1.)                          && 
			   (p2 == 1. || p4 == 1. || p6 == 1.) && 
			   (p4 == 1. || p6 == 1. || p8 == 1.) ) 
				  pass = 1.;
				  
		} else if(process == 1) {
			if((p1 == 0.)                         && 
			   (2. <= b && b <= 6.)               && 
			   (a == 1.)                          && 
			   (p2 == 1. || p4 == 1. || p8 == 1.) && 
			   (p2 == 1. || p6 == 1. || p8 == 1.) ) 
				  pass = 1.;
		}
		
	}
	
	gl_FragColor = vec4(vec3(pass), 1.);
}