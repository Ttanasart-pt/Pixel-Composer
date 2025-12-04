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

#define PI 3.14159265358979323846

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

float gaussian(float sigma, float pos) { return (1.0 / sqrt(2.0 * PI * sigma * sigma)) * exp(-(pos * pos) / (2.0 * sigma * sigma)); }
        
void main() {
	vec2 tx = 1. / dimension;
	int   kernelRadius = 5;
    float kernelSum    = 0.0;
    
    vec4  col = vec4(0.);

    for (int x = -kernelRadius; x <= kernelRadius; ++x) {
        vec4 c = sampleTexture(gm_BaseTexture, v_vTexcoord + vec2(x, 0.) * tx, float(x)/float(kernelRadius));
        float gauss = gaussian(2.0, float(x));

        col += c * gauss;
        kernelSum += gauss;
    }

    gl_FragColor = col / kernelSum;
}