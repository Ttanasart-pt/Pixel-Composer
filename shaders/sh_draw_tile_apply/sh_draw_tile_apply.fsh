varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
    vec4 draw = texture2D( gm_BaseTexture, v_vTexcoord );
    
    if(draw.a == 0.) discard;
    gl_FragColor = draw;
}
