varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float index[1024];
uniform int   axis;
uniform int   shift;

void main() {
    vec2 tx = 1. / dimension;
    vec2 px = floor(v_vTexcoord * dimension);
    
    gl_FragColor = vec4(0.);
    
    if(axis == 0) {
        int   ind = int(min(px.x, 1024.));
        float npx = mod(index[ind] + .5 + (shift == 1? px.y : 0.), dimension.x);
        
        gl_FragColor = texture2D( gm_BaseTexture, vec2(tx.x * npx, v_vTexcoord.y) );
        
    } else if(axis == 1) {
        int   ind = int(min(px.y, 1024.));
        float npy = mod(index[ind] + .5 + (shift == 1? px.x : 1.), dimension.y);
        
        gl_FragColor = texture2D( gm_BaseTexture, vec2(v_vTexcoord.x, tx.y * npy) );
    }
}
