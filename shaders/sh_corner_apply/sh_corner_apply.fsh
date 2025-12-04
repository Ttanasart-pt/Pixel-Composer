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

uniform vec2      dimension;
uniform float     radius;
uniform float     thershold;
uniform sampler2D original;

void main() {
	gl_FragColor = vec4(0., 0., 0., 1.);
	
	vec4 cc = texture2D(gm_BaseTexture, v_vTexcoord);
	if(cc.a == 0.) return;
	
	vec2 tx = 1. / dimension;
	float kfill = 0.;
	float ksize = 0.;
	
	for(float i = -16.; i <= 16.; i++)
	for(float j = -16.; j <= 16.; j++) {
		if(abs(i) > radius || abs(j) > radius) continue;
		
		vec4 samp = sampleTexture(gm_BaseTexture, v_vTexcoord + vec2(i, j) * tx);
		ksize++;
		
		if(samp.rg != cc.rg) continue;
		kfill += samp.a;
	}
	
	bool isCorner = (kfill / ksize) < thershold;
	
	if(!isCorner) gl_FragColor = texture2D(original, v_vTexcoord);
}