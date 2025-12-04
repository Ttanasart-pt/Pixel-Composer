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

uniform int   size;
uniform vec2  dimension;
uniform float kernel[256];
uniform int   normalized;

void main() {
	vec2  tx  = 1. / dimension;
	float sum = 1.;
	
	if(normalized == 1) {
		sum = 0.;
		int amo = size * size;
		for(int i = 0; i < amo; i++) sum += kernel[i];
		
		if(sum == 0.) sum = 1.;
	}
	
	float st = -(float(size) - 1.) / 2.;
	vec4  c  = vec4(0.);
	
	for(int i = 0; i < size; i++)
	for(int j = 0; j < size; j++) {
		int  index = i * size + j;
		vec2 px    = v_vTexcoord + vec2((float(j) + st) * tx.x, (float(i) + st) * tx.y);
		
		float w = kernel[index];
		if(w == 0.) continue;
		
		c += w * sampleTexture( gm_BaseTexture, px) / sum;
	}
	
    gl_FragColor = c;
}
