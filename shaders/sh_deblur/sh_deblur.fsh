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

uniform int   method;
uniform float radius;
uniform float strength;
uniform float noiseSuppress;

uniform float gaussianWeights[5];

vec4 unsharpMask(vec2 uv) {
    vec4 original = sampleTexture(gm_BaseTexture, uv);
    vec4 blurred = vec4(0.0);
    
    for(int i = 0; i < 5; i++) {
        vec2 offset = vec2(float(i - 2) * radius / dimension.x, 0.0);
        blurred += sampleTexture(gm_BaseTexture, uv + offset) * gaussianWeights[i];
    }
    
    vec4 finalBlur = vec4(0.0);
    for(int i = 0; i < 5; i++) {
        vec2 offset = vec2(0.0, float(i - 2) * radius / dimension.y);
        finalBlur += sampleTexture(gm_BaseTexture, uv + offset) * gaussianWeights[i];
    }
    
    vec4 sharp = original + (original - finalBlur) * strength;
    
    // Noise suppression
    float diff    = length(original.rgb - finalBlur.rgb);
    float suppress = smoothstep(0.0, noiseSuppress, diff);
    
    return mix(original, clamp(sharp, 0.0, 1.0), suppress);
}

vec4 edgeEnhancement(vec2 uv) {
    vec4 center = sampleTexture(gm_BaseTexture, uv);
    vec4 result = center * (1.0 + 4.0 * strength);
    
    // Edge detection kernel (Laplacian)
    vec2 offsets[4];

	offsets[0] = vec2(0,  radius / dimension.y);
	offsets[1] = vec2(0, -radius / dimension.y);
	offsets[2] = vec2( radius / dimension.x, 0);
	offsets[3] = vec2(-radius / dimension.x, 0);
    
    for(int i = 0; i < 4; i++)
        result -= sampleTexture(gm_BaseTexture, uv + offsets[i]) * strength;
    
    return clamp(result, 0.0, 1.0);
}

vec4 wienerFilter(vec2 uv) {
    vec4 result = vec4(0.0);
    
    // Wiener deconvolution kernel (approximation)
    float kernel[9];
    
	kernel[0] = -0.1 * strength;
	kernel[1] = -0.1 * strength;
	kernel[2] = -0.1 * strength;
	kernel[3] = -0.1 * strength;
	kernel[4] =  1.0 + 0.8 * strength;
	kernel[5] = -0.1 * strength;
	kernel[6] = -0.1 * strength;
	kernel[7] = -0.1 * strength;
	kernel[8] = -0.1 * strength;
    
    for(int i = 0; i < 3; i++) {
        for(int j = 0; j < 3; j++) {
            vec2 offset = vec2(float(i-1), float(j-1)) * radius / dimension;
            result += sampleTexture(gm_BaseTexture, uv + offset) * kernel[i*3+j];
        }
    }
    
    // Noise suppression
    vec4  original = sampleTexture(gm_BaseTexture, uv);
    float noise    = length(result.rgb - original.rgb);
    float suppress = smoothstep(noiseSuppress, 0.0, noise);
    
    return mix(original, clamp(result, 0.0, 1.0), suppress);
}

void main() {
    vec2 uv = v_vTexcoord;
    
         if(method == 0) gl_FragColor = unsharpMask(uv);
    else if(method == 1) gl_FragColor = edgeEnhancement(uv);
    else if(method == 2) gl_FragColor = wienerFilter(uv);
    else gl_FragColor = sampleTexture(gm_BaseTexture, uv);
    
    gl_FragColor.a = sampleTexture(gm_BaseTexture, uv).a;
}