#ifdef _YY_HLSL11_ 
    #define COL_MAX  1024
#else 
    #define COL_MAX  256
#endif

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4  colorFrom[COL_MAX];
uniform float colorTo[COL_MAX];
uniform int   colorAmount;

void main() {
    vec4 base = texture2D( gm_BaseTexture, v_vTexcoord );
    gl_FragColor = base;
    
    for(int i = 0; i < colorAmount; i++) {
        if(base == colorFrom[i])
            gl_FragColor = vec4(colorTo[i], 0., 0., 1.) * v_vColour;
    }
}
