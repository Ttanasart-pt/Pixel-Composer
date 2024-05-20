#define PALETTE_LIMIT 128

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  paletteSize;
uniform vec4 palette[PALETTE_LIMIT];
uniform vec2 positions[PALETTE_LIMIT];

uniform float influence;
uniform float progress;

void main() {
    vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
    if(c.a > 0.) {
        gl_FragColor = c;
        return;
    }
    
    vec4 cc = vec4(0.);
    float w = 0.;
    float minDist = 999.;
    
    for(int i = 0; i < paletteSize; i++) {
        vec4 pal = palette[i];
        vec2 pos = positions[i] / dimension;
        
        if(v_vTexcoord == pos) {
            gl_FragColor = pal;
            return;
        }
        
        float dist = distance(v_vTexcoord, pos);
        dist = 1. / pow(dist, influence);
        
        cc += pal * dist;
        w  += dist;
        
        minDist = min(minDist, dist);
    }
    
    if(w > 0.) cc /= w;
    
    if(progress < 1.) {
        cc.a = smoothstep(0., cc.a, progress * minDist);
    }
    
    gl_FragColor = cc;
}
