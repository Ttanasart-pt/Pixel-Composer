varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4  colorFrom[1024];
uniform float colorTo[1024];
uniform int   colorAmount;

void main() {
    vec4 base = texture2D( gm_BaseTexture, v_vTexcoord );
    gl_FragColor = base;
    
    for(int i = 0; i < colorAmount; i++) {
        if(base == colorFrom[i])
            gl_FragColor = vec4(colorTo[i], 0., 0., 1.);
    }
}
