varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D drawSurface;

uniform int indexes[1024];
uniform int indexSize;

void main() {
    int   ss = int(texture2D( gm_BaseTexture, v_vTexcoord )[0] - 1.);
    float dd = texture2D( drawSurface, v_vTexcoord )[0];
    
    vec4 res = vec4(0.);
    
    for(int i = 0; i < indexSize; i++) {
        if(indexes[i] == -1) continue;
        if(ss == indexes[i])
            res[0] = .5;
    }
    
    res[0] = max(res[0], dd);
    
    gl_FragColor = res;
}
