varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D selectionMask;

void main() {
    vec4 draw = texture2D( gm_BaseTexture, v_vTexcoord );
    vec4 mask = texture2D( selectionMask,  v_vTexcoord );
    
    if(mask.r ==  0.) discard;
    if(draw.r == -1.) discard;
    
    gl_FragColor = draw;
}
