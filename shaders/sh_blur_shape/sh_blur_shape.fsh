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

uniform sampler2D blurMask;
uniform vec2 blurMaskDimension;

uniform int useMask;
uniform sampler2D mask;

uniform int mode;
uniform int gamma;

float sampleMask() {
	if(useMask == 0) return 1.;
	vec4 m = texture2D( mask, v_vTexcoord );
	return (m.r + m.g + m.b) / 3. * m.a;
}

float sampleBlurMask(vec2 pos) {
	vec4 m = texture2D( blurMask, 1. - pos );
	return (m.r + m.g + m.b) / 3. * m.a;
}

void main() {
	gl_FragColor = sampleTexture( gm_BaseTexture, v_vTexcoord );
	
	vec2 px   = v_vTexcoord * dimension;
	vec2 tx   = 1. / dimension;
	float msk = sampleMask();
	if(msk == 0.) return;
	
	float bs  = 1. / msk;
	
	vec4  col    = vec4(0.);
	float weight = 0.;
	
	vec2 bdim2 = blurMaskDimension / 2.;
	
	for(float i = 0.; i <= 64.; i++)
	for(float j = 0.; j <= 64.; j++) {
		if(i >= blurMaskDimension.x || j >= blurMaskDimension.y) continue;
		
		vec2 bPx = (vec2(i, j) - bdim2) * bs;
		vec2 bRx = bPx / blurMaskDimension;
		if(abs(bRx.x) >= .5 || abs(bRx.y) >= .5) continue;
		
		vec4  c = sampleTexture( gm_BaseTexture, (px + bPx) * tx, length(bRx * 2.));
		float b = sampleBlurMask(bRx + 0.5);
		
		if(gamma == 1) c.rgb = pow(c.rgb, vec3(2.2));
		
		if(mode == 0) {
			col    += c * b;
			weight += b;
			
		} else if(mode == 1) {
			col     = max(col, c * b);
		}
	}
	
	     if(mode == 0) col /= weight;
	else if(mode == 1) col.a = 1.;
	
	if(gamma == 1) col.rgb = pow(col.rgb, vec3(1. / 2.2));
	
	gl_FragColor = col;
}
