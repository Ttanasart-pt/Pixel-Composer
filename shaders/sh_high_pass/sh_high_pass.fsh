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

uniform vec2  dimension;
uniform float radius;
uniform float intensity;

void main() {
    vec2  tx = 1. / dimension;
    vec4  ss = vec4(0.);
    float ww = 0.;
    
    for(float i = -radius; i <= radius; i++)
    for(float j = -radius; j <= radius; j++) {
        if(i == 0. && j == 0.) continue;
        
        vec2 sx = v_vTexcoord + vec2(i, j) * tx;
        float w = (radius - (abs(i) + abs(j)) + 1.) / radius / 4.;
        if(w <= 0.) continue;
        
        ss -= sampleTexture( gm_BaseTexture, sx ) * w;
        ww += w;
    }
    
    vec4 sc = sampleTexture( gm_BaseTexture, v_vTexcoord );
    ss += sc * ww;
    
    gl_FragColor = vec4(ss.rgb * intensity, sc.a);
}
