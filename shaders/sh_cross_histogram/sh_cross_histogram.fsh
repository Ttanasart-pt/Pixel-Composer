varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform sampler2D surface;

void main() {
    vec2 tx = 1. / dimension;
    
    gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
}
